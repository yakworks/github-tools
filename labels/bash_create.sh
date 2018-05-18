#!/usr/bin/env bash

### REQUIRES BASH 4 FROM WHAT I UNDERSTAND, on my mac I use `brew install bash`
# and the shebang above #!/usr/local/bin/bash

#Taken from here https://gist.github.com/MatthiasKunnen/b7c4f812ddc6a8bb217160ab4f048e0c
#and here https://gist.github.com/omegahm/28d87a4e1411c030aa89
# Colours picked from https://robinpowered.com/blog/best-practice-system-for-organizing-and-tagging-github-issues/

###
# Label definitions
###
declare -A LABELS

# Priority
LABELS["Priority: Blocker"]="ee0701"
LABELS["Priority: Critical"]="d93f0b"
LABELS["Priority: Major"]="ff7138"
LABELS["Priority: Minor"]="ffa700"
LABELS["Priority: Trivial"]="ffce71"

# var colors = {
#   'duplicate': 'ededed',
#   'greenkeeper': 'ededed',
#   'starter': 'ffc0cb',
#   'Priority: Critical': 'ee0701',
#   'Priority: High': 'd93f0b',
#   'Priority: Low': '0e8a16',
#   'Priority: Medium': 'fbca04',
#   'Status: Abandoned': '000000',
#   'Status: Available': 'c2e0c6',
#   'Status: Blocked': 'ee0701',
#   'Status: In Progress': 'cccccc',
#   'Status: On Hold': 'e99695',
#   'Status: Proposal': 'd4c5f9',
#   'Status: Review Needed': 'fbca04',
#   'Type: Bug': 'ee0701',
#   'Type: Documentation': '5319e7',
#   'Type: Enhancement': '1d76db',
#   'Type: Maintenance': 'fbca04',
#   'Type: Question': 'cc317c'
# }


# Problems
# LABELS["bug"]="EE3F46"
# LABELS["security"]="EE3F46"
# LABELS["production"]="F45D43"

# # Mindless
# LABELS["chore"]="FEF2C0"
# LABELS["refactoring"]="FEF2C0"

# # Experience
# LABELS["copy"]="FFC274"
# LABELS["design"]="FFC274"
# LABELS["ux"]="FFC274"

# # Environment
# LABELS["staging"]="FAD8C7"
# LABELS["test"]="FAD8C7"

# # Feedback
# LABELS["discussion"]="CC317C"
# LABELS["rfc"]="CC317C"
# LABELS["question"]="CC317C"

# # Improvements
# LABELS["enhancement"]="5EBEFF"
# LABELS["optimizaiton"]="5EBEFF"

# # Additions
# LABELS["feature"]="91CA55"

# # Pending
# LABELS["in progress"]="FBCA04"
# LABELS["watchlist"]="FBCA04"

# # Inactive
# LABELS["invalid"]="D2DAE1"
# LABELS["wontfix"]="D2DAE1"
# LABELS["duplicate"]="D2DAE1"
# LABELS["on hold"]="D2DAE1"

###
# Get a token from Github
###
if [ ! -f ".token" ]; then
  read -p "Please enter your Github username: " user
  read -p "Please enter your 6 digit two-factor-authentication code: " otp_code

  curl -u "$user" -H "X-Github-OTP: $otp_code" -d '{"scopes":["repo", "public_repo"], "note":"Creating Labels"}' "https://api.github.com/authorizations" | jq -r '.token' > .token
fi

TOKEN=$(cat .token)

read -p "Repo slug in format owner/repo :" owner
read -p "What repo do you want labels on?: " repo

for K in "${!LABELS[@]}"; do
  CURL_OUTPUT=$(curl -s -H "Authorization: token $TOKEN" -X POST "https://api.github.com/repos/$repo/labels" -d "{\"name\":\"$K\", \"color\":\"${LABELS[$K]}\"}")
  HAS_ERROR=$(echo "$CURL_OUTPUT" | jq 'has("errors")')

  if [ "$HAS_ERROR" = true ]; then
    ERROR=$(echo "$CURL_OUTPUT" | jq -r '.errors[0].code')

    if [ "$ERROR" == "already_exists" ]; then
      # We update
      echo "'$K' already exists. Updating..."
      CURL_OUTPUT=$(curl -s -H "Authorization: token $TOKEN" -X PATCH "https://api.github.com/repos/$repo/labels/${K/ /%20}" -d "{\"name\":\"$K\", \"color\":\"${LABELS[$K]}\"}")
    else
      echo "Unknown error: $ERROR"
      echo "Output from curl: "
      echo "$CURL_OUTPUT"
      echo "Exiting..."
      exit;
    fi
  else
    echo "Created '$K'."
  fi
done