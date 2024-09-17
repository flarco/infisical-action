import os, json, pathlib, sys

github_env_multiline_template = '''
{k}<<EEEE123123OOOO987987FFFFF
{v}
EEEE123123OOOO987987FFFFF'
'''

secret_multiline_template = '''
echo '{k}<<EEEE123123OOOO987987FFFFF
{v}
EEEE123123OOOO987987FFFFF' >> "$GITHUB_ENV"
'''

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

  github_env_file = os.environ['GITHUB_ENV']

  secret_lines = ['#!/usr/bin/env bash']
  mask_lines = ['']
  github_env_lines = []
  env_lines = []
  env_sh_lines = []

  for secret in secrets:
    k = secret['key']
    val = secret['value']
    
    v = val.replace("'", """'"'"'""") # escape single quote

    # so the value is masked
    if '\n' in val:
      github_env_lines.append(github_env_multiline_template.replace('{k}', k).replace('{v}', v))
      secret_lines.append(secret_multiline_template.replace('{k}', k).replace('{v}', v))
      for l in v.splitlines():
        mask_lines.append("""echo '::add-mask::{l}'""".format(l=l.strip()))
    else:
      github_env_lines.append("""{k}={v}""".format(k=k, v=v))
      secret_lines.append("""echo '{k}={v}' >> $GITHUB_ENV""".format(k=k, v=v))
      if v.strip(): mask_lines.append("""echo '::add-mask::{v}'""".format(v=v.strip()))
      env_lines.append("""{k}='{v}'""".format(k=k, v=v))
      env_sh_lines.append("""export '{k}'='{v}'""".format(k=k, v=v))
    

  # replace re-used env vars
  for secret in secrets:
    k = secret['key']
    val = secret['value']
    
    key = '${' + k + '}'
    for i, _ in enumerate(secret_lines):
      secret_lines[i] = secret_lines[i].replace(key, val)
    for i, _ in enumerate(env_lines):
      env_lines[i] = env_lines[i].replace(key, val)

  print('writing to $GITHUB_ENV', flush=True)
  with open(github_env_file, 'a') as file:
    file.write('\n')
    for line in github_env_lines:
      file.write(line + '\n')

  # print('writing secrets.sh', flush=True)
  # with open('secrets.sh', 'w') as file:
  #   file.write('\n'.join(secret_lines).replace('\r', ''))

  with open('masks.sh', 'w') as file:
    file.write('\n'.join(mask_lines).replace('\r', ''))

  if os.getenv('DOTENV') == 'true':
    print('writing .env', flush=True)
    with open('.env', 'w') as file:
      file.write('\n'.join(env_lines).replace('\r', ''))

  if os.getenv('DOTENV_SH') == 'true':
    print('writing .env.sh', flush=True)
    with open('.env.sh', 'w') as file:
      file.write('\n'.join(env_sh_lines).replace('\r', ''))


if __name__ == '__main__':
  args = sys.argv[1:]
  if len(args) == 0: print('missing arg.')
  elif args[0] in locals(): locals()[args[0]](*args[1:])
  else: print('invalid arg: '+args[0])
