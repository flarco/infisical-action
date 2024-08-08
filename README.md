# infisical-action
Action to Inject Infisical Secrets in your environment

# Inputs

```yaml
  version:
    description: 'The CLI version to use (e.g. 0.28.1). Check https://github.com/Infisical/infisical/tags'
    required: true
  
  client_id:
    description: 'The client-id value, typically secrets.INFISICAL_CLIENT_ID'
    required: true

  client_secret:
    description: 'The client-secret value, typically secrets.INFISICAL_CLIENT_SECRET'
    required: true

  project_id:
    description: 'The project-id or workspace-id value.'
    required: true

  env:
    description: The environment to use. If not set, will use .infisical.json
    required: false

  path:
    description: 'The secrets path value'
    required: false
    default: '/'

  dotenv:
    description: 'Create a .env file in the root folder. Accepts `true` or `false`'
    required: false

  dotenv_sh:
    description: 'Create a .env.sh file in the root folder. Accepts `true` or `false`'
    required: false
```

# Example

```yaml
- uses: flarco/infisical-action@v1
  with:
    version: 0.28.1
    client_id: ${{ secrets.INFISICAL_CLIENT_ID }}
    client_secret: ${{ secrets.INFISICAL_CLIENT_SECRET }}
    project_id: ${{ secrets.INFISICAL_PROJECT_ID }}
    env: staging
    path: /
```
