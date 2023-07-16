read -p "Enter commit message: " commit_message
flutter build web --release
firebase deploy
git add .
git commit -m "$commit_message"
git push -u origin main
