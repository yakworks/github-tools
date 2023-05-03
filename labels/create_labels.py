import json
import requests
import yaml
import os

#token = raw_input('Paste your GitHub token? (see https://github.com/settings/tokens): ')
#repo = raw_input('Which repo do you want to setup? (e.g. Wiredcraft/test): ')

token = os.environ.get('GITHUB_TOKEN')
if token == '':
  token = raw_input('Env var not set, Paste your GitHub token? (see https://github.com/settings/tokens): ')
  pass

with open('labels.yml', 'r') as f:
  labelsYml = yaml.load(f, Loader=yaml.FullLoader)

default_labels = labelsYml['labels']
url = '' # setup below
#token = labelsYml['token']
headers = {'Authorization': 'token %s' % token,
  'Accept': 'application/vnd.github.v3+json',
  'Accept': 'application/vnd.github.symmetra-preview+json'}  #allows description to be inserted

def get_labels():
  try:
    response = requests.get(url, headers=headers)
    response.raise_for_status() # optional but good practice in case the call fails!
    return [label['name'] for label in response.json()]
  except Exception as e:
    return e

def set_labels(labels):
  for label in default_labels:
    try:
      # Label was in the list, we update GH
      labels.remove(label['name'])
      update_label(label)
    except ValueError:
      # Label wasn't in the array, we add it to GH
      create_label(label)

  # We now remove the labels left if setting is true
  if labelsYml.get('deleteLabels', False):
    for label in labels:
       delete_label(label)

def update_label(label):
  print('Update label (%s) on GH' % label)
  try:
    response = requests.patch(url + '/' + label['name'], data=json.dumps(label), headers=headers)
    response.raise_for_status()
    return response.json()
  except Exception as e:
    return e

def create_label(label):
  print('Create label (%s) on GH' % label['name'])
  try:
    response = requests.post(url, data=json.dumps(label), headers=headers)
    response.raise_for_status()
    return response.json()
  except Exception as e:
    return e

def delete_label(label):
  print('Delete label (%s) from GH' % label)
  try:
    response = requests.delete(url + '/' + label, headers=headers)
    response.raise_for_status()
    return response.json()
  except Exception as e:
    return e

for repo in labelsYml['repos']:
  url = 'https://api.github.com/repos/' + repo + '/labels'
  labels = get_labels()
  set_labels(labels)
