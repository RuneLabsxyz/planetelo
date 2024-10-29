# Profile
if [ $# -ge 1 ]; then
  export PROFILE=$1
else
  export PROFILE="slot"
fi
export DOJO_PROFILE_FILE="dojo_$PROFILE.toml"


sozo migrate --profile $PROFILE plan
sozo migrate --profile $PROFILE apply
