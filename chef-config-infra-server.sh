USER_NAME='mike'
FIRST_NAME='Mike'
LAST_NAME='Bomba'
EMAIL='mike.bomba@progress.com'
PASSWORD='Kemp1fourall'
FULL_ORGANIZATION_NAME='test demo site'
SHORT_NAME='test-demo'
ORGANIZATION='test-demo'
if [ -f "./$USER_NAME.pem" ]
  then
    :
  else
  sudo chef-server-ctl user-create "$USER_NAME" "$FIRST_NAME" "$LAST_NAME" "$EMAIL" "$PASSWORD" --filename "$USER_NAME.pem"
fi

if [ -f "./$ORGANIZATION-validator.pem" ]
  then
    :
  else
    sudo chef-server-ctl org-create "$SHORT_NAME" "$FULL_ORGANIZATION_NAME" --association_user "$USER_NAME" --filename "$ORGANIZATION-validator.pem"
fi
