#!/bin/bash
set -e

# Generate a random IAM user name using the current timestamp and a random number
NEW_USER="newuser-$(date +%s)-$RANDOM"
POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

echo "Creating IAM user: ${NEW_USER}"
aws iam create-user --user-name "${NEW_USER}"

echo "Creating programmatic access keys for: ${NEW_USER}"
aws iam create-access-key --user-name "${NEW_USER}" > new_user_keys.json

echo "Attaching policy ${POLICY_ARN} to user: ${NEW_USER}"
aws iam attach-user-policy --user-name "${NEW_USER}" --policy-arn "${POLICY_ARN}"

# Extract AccessKeyId and SecretAccessKey from JSON using jq
ACCESS_KEY=$(jq -r '.AccessKey.AccessKeyId' new_user_keys.json)
SECRET_KEY=$(jq -r '.AccessKey.SecretAccessKey' new_user_keys.json)

# Display new credentials (be cautious when logging sensitive data)
echo "New user's Access Key ID: ${ACCESS_KEY}"
echo "New user's Secret Access Key: ${SECRET_KEY}"

# Unset any interfering temporary credentials
unset AWS_SESSION_TOKEN
unset AWS_SECURITY_TOKEN
unset AWS_PROFILE
unset AWS_DEFAULT_PROFILE

# Allow some time for the new credentials to propagate
echo "Waiting 5 seconds for new credentials to propagate..."
sleep 5

# Verify new credentials using inline environment variables
echo "Verifying by calling sts get-caller-identity with inline environment variables:"
AWS_ACCESS_KEY_ID="${ACCESS_KEY}" \
AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" \
AWS_DEFAULT_REGION="us-east-1" \
aws sts get-caller-identity

# Optionally, configure and use a new AWS CLI profile:
echo "Configuring new AWS CLI profile 'newuser'..."
aws configure set aws_access_key_id "${ACCESS_KEY}" --profile newuser
aws configure set aws_secret_access_key "${SECRET_KEY}" --profile newuser
aws configure set region us-east-1 --profile newuser

echo "Verifying by calling sts get-caller-identity with profile 'newuser':"
aws sts get-caller-identity --profile newuser

# Now list S3 buckets using inline credentials
echo "Listing S3 buckets using inline environment variables:"
AWS_ACCESS_KEY_ID="${ACCESS_KEY}" \
AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" \
AWS_DEFAULT_REGION="us-east-1" \
aws s3 ls --profile newuser

# Clean up temporary file
rm new_user_keys.json
