import os, pathlib, sys
import json

# check if .infisical.json exists
if not pathlib.Path('.infisical.json').exists():
  sys.stdout.write(os.getenv('INFISICAL_PROJECT_ID'))
  exit()

# Load the .infisical.json file
with open('.infisical.json', 'r') as file:
  data = json.load(file)

# Get the workspaceId from the file
workspace_id = data.get('workspaceId')

# Set INFISICAL_PROJECT_ID if it's empty and workspaceId is available
if not os.getenv('INFISICAL_PROJECT_ID') and workspace_id:
  sys.stdout.write(workspace_id)
else:
  sys.stdout.write(os.getenv('INFISICAL_PROJECT_ID'))