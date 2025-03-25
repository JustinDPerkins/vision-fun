#!/bin/bash
set -e

# Define variables for the new user
NEW_USER="new-iam-user"  # Change to desired username
POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

echo "Creating IAM user: ${NEW_USER}"
aws iam create-user --user-name "${NEW_USER}"

echo "Creating programmatic access keys for: ${NEW_USER}"
# Create access key and capture the output in a JSON file
aws iam create-access-key --user-name "${NEW_USER}" > new_user_keys.json

# Attach the AdministratorAccess policy to the new user
echo "Attaching policy ${POLICY_ARN} to user: ${NEW_USER}"
aws iam attach-user-policy --user-name "${NEW_USER}" --policy-arn "${POLICY_ARN}"

# Extract AccessKeyId and SecretAccessKey from the JSON output
ACCESS_KEY=$(jq -r '.AccessKey.AccessKeyId' new_user_keys.json)
SECRET_KEY=$(jq -r '.AccessKey.SecretAccessKey' new_user_keys.json)

# Optionally, output the new keys (be cautious with this step in production)
echo "New user's Access Key ID: ${ACCESS_KEY}"
echo "New user's Secret Access Key: ${SECRET_KEY}"

# Export new credentials for subsequent AWS CLI commands in this session
export AWS_ACCESS_KEY_ID="${ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${SECRET_KEY}"

echo "Switched AWS CLI to use the new IAM user: ${NEW_USER}"
echo "Verifying by calling sts get-caller-identity:"
aws sts get-caller-identity

# Cleanup: Optionally remove the temporary JSON file
rm new_user_keys.json
