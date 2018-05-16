# github-tools
General tooling/scripts to keep our projects and repos consistent such as setting up standard labels, issue templates, PR reviews etc..

## GitHub Labels

Forked from here https://github.com/Wiredcraft/gh-labels

We wasted a lot of time setting up labels on GitHub every time we create a new repo. We wanted a way to just
automate that process, especially since we have a standard list of labels we use for all our projects.

This little Python script prompts you for a GitHub repository (and a GitHub token)
and set up the labels for this repo to match what you have in a [`labels.yml`](labels/labels.yml) file. This file includes a simple
list of label settings;

get a token from https://github.com/settings/tokens

```
token: 6fa8b6510.....
deleteLabels: true # removes the github repo labels if not in the list below
repos:
  - yakworks/sandbox
  - yakworks/idea-bank
labels:
  - name: 'Status: On Deck'
    color: 'fbca04'
  - name: 'Status: On Hold'
    color: 'c5def5'
(...)
```

### Install & Run

1. Get in the label folder. Edit the labels.yml the way you want them.
1. add env var GH_WRITE_TOKEN to the token from https://github.com/settings/tokens. you will be prompted for it if you don't.
1. Optional: Create and activate your virtualenv;

        virtualenv venv
        source venv/bin/activate

1. Install dependencies; `pip or pip3 install -r requirements.txt`
1. Run it; `python create_labels.py`

