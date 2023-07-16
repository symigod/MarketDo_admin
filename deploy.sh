read -p "Enter commit message: " commit_message
echo "=================================================="
echo "Running flutter build web --release ..."
echo "=================================================="
flutter build web --release

echo "=================================================="
echo "Running firebase deploy ..."
echo "=================================================="
firebase deploy

echo "=================================================="
echo "Running git add . ..."
echo "=================================================="
git add .

echo "=================================================="
echo "Running git commit -m "$commit_message" ..."
echo "=================================================="
git commit -m "$commit_message"

echo "=================================================="
echo "Running git push -u origin main ..."
echo "=================================================="
git push -u origin main