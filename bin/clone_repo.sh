read -p 'GitHub Username: ' github_username
read -p 'GitHub Repo Name: ' github_repo_name

## Clone Hugo Repo
git clone https://github.com/synax/project-asgard-hugo.git /project-asgard-hugo
cd /project-asgard-hugo
git remote rm origin
git remote add origin https://github.com/$github_username/$github_repo_name.git
git pull --no-edit https://github.com/$github_username/$github_repo_name.git master
git push origin master