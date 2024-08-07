# infisical-action
Action to Inject Infisical Secrets in your environment


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
