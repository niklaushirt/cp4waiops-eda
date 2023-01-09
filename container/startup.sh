
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🌏  Get Code from $REPO_URL"
git clone $REPO_URL repo | sed 's/^/      /'
cd repo

./startup.sh
