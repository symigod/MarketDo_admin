#!/bin/bash

while true; do
    echo "Please choose an option:"
    echo "1. BUILD RELEASE"
    echo "2. DEPLOY TO FIREBASE"
    echo "3. PUSH TO GITHUB"
    echo "4. PERFORM ALL OPTIONS (1-3)"
    echo "5. CANCEL/EXIT"

    read -p "Enter your choice: " choice

    if [ "$choice" = "1" ]; then
        echo "=================================================="
        echo "Running flutter build web --release ..."
        echo "=================================================="
        flutter build web --release

    elif [ "$choice" = "2" ]; then
        echo "=================================================="
        echo "Running firebase deploy ..."
        echo "=================================================="
        firebase deploy

    elif [ "$choice" = "3" ]; then
        read -p "Enter commit message: " commit_message

        echo "=================================================="
        echo "Running git add . ..."
        echo "=================================================="
        git add .

        echo "=================================================="
        echo "Running git commit -m \"$commit_message\" ..."
        echo "=================================================="
        git commit -m "$commit_message"

        echo "=================================================="
        echo "Running git push -u origin main ..."
        echo "=================================================="
        git push -u origin main

    elif [ "$choice" = "4" ]; then
        echo "=================================================="
        echo "Running flutter build web --release ..."
        echo "=================================================="
        flutter build web --release

        echo "=================================================="
        echo "Running firebase deploy ..."
        echo "=================================================="
        firebase deploy

        read -p "Enter commit message: " commit_message

        echo "=================================================="
        echo "Running git add . ..."
        echo "=================================================="
        git add .

        echo "=================================================="
        echo "Running git commit -m \"$commit_message\" ..."
        echo "=================================================="
        git commit -m "$commit_message"

        echo "=================================================="
        echo "Running git push -u origin main ..."
        echo "=================================================="
        git push -u origin main

    elif [ "$choice" = "5" ]; then
        echo "Exiting..."
        exit 0

    else
        echo "Invalid choice."
    fi

    read -p "Press Enter to continue..."
done
