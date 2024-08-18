import os, json, pathlib, sys


def load_from_infisical():
  # parse and load from .infisical.json

  file = pathlib.Path('.infisical.json')

  if not file.exists():
    # INFISICAL_PATH defaults
    if not os.getenv('INFISICAL_PATH'):
      os.environ['INFISICAL_PATH'] = '/'

    if not os.getenv('INFISICAL_PROJECT_ID'):
      raise Exception('PROJECT_ID needs to be set in the workflow or in .infisical.json (with "workspaceId")')
  else:
    with file.open() as f:
      data = json.load(f)

    if 'secretPath' in data:
      os.environ['INFISICAL_PATH'] = data['secretPath']

    if 'workspaceId' in data:
      os.environ['INFISICAL_PROJECT_ID'] = data['workspaceId']
  

  with open('params.json', 'w') as f:
    data = {
      'INFISICAL_PATH': os.environ['INFISICAL_PATH'],
      'INFISICAL_PROJECT_ID': os.environ['INFISICAL_PROJECT_ID'],
    }
    f.write(json.dumps())

def make_secrets():
  with open('env.json') as file:
    secrets = json.load(file)

  # delete the env.json file
  os.remove('env.json')

  multiline_template = '''
  echo '{k}<<EEEE123123OOOO987987FFFFF
  {v}
  EEEE123123OOOO987987FFFFF' >> "$GITHUB_ENV"
  '''

  bash_lines = ['#!/usr/bin/env bash', '']
  mask_lines = ['#!/usr/bin/bash', '']
  env_lines = []
  env_sh_lines = []

  for secret in secrets:
    k = secret['key']
    val = secret['value']
    
    v = val.replace("'", """'"'"'""") # escape single quote

    # so the value is masked
    if '\n' in val:
      bash_lines.append(multiline_template.replace('{k}', k).replace('{v}', v))
      for l in v.splitlines():
        mask_lines.append(f"""echo '::add-mask::{l.strip()}'""")
    else:
      bash_lines.append(f"""echo '{k}={v}' >> $GITHUB_ENV""")
      mask_lines.append(f"""echo '::add-mask::{v.strip()}'""")
      env_lines.append(f"""{k}='{v}'""")
      env_sh_lines.append(f"""export '{k}'='{v}'""")
    

  # replace re-used env vars
  for secret in secrets:
    k = secret['key']
    val = secret['value']
    
    key = '${' + k + '}'
    for i, _ in enumerate(bash_lines):
      bash_lines[i] = bash_lines[i].replace(key, val)
    for i, _ in enumerate(env_lines):
      env_lines[i] = env_lines[i].replace(key, val)

  print('writing secrets.sh', flush=True)
  with open('secrets.sh', 'w') as file:
    file.write('\n'.join(bash_lines))

  with open('masks.sh', 'w') as file:
    file.write('\n'.join(mask_lines))

  if os.getenv('DOTENV') == 'true':
    print('writing .env', flush=True)
    with open('.env', 'w') as file:
      file.write('\n'.join(env_lines))

  if os.getenv('DOTENV_SH') == 'true':
    print('writing .env.sh', flush=True)
    with open('.env.sh', 'w') as file:
      file.write('\n'.join(env_sh_lines))


if __name__ == '__main__':
  args = sys.argv[1:]
  if len(args) == 0: print('missing arg.')
  elif args[0] in locals(): locals()[args[0]](*args[1:])
  else: print('invalid arg: '+args[0])