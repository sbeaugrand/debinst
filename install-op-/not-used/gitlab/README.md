# ansible-role-gitlab
```sh
cd roles
git clone https://github.com/geerlingguy/ansible-role-gitlab.git
vi ansible-role-gitlab/tasks/main.yml +/async  # comment async and poll
```

# gitlab vm
```sh
cd gitlab
vagrant up
vagrant ssh
sudo gitlab-rake "gitlab:password:reset"
ip -c a
```

# host
```sh
sudo vi /etc/hosts +  # 192.168.121.193 gitlab
https://gitlab/admin/users/new
https://gitlab/-/profile/personal_access_tokens
Token name: project
scopes: api,read,write
glpat-kesdgfmV139azwSUGNRB
```

# buildvm
```sh
cd buildvm
vi playbook.yml  # ip, api_token
vagrant up
vagrant ssh
echo | openssl s_client -servername gitlab -connect gitlab:443 -showcerts | sudo tee /etc/ssl/certs/gitlab.pem >/dev/null
sudo update-ca-certificates --fresh
#FIXME
openssl s_client -connect gitlab:443 </dev/null 2>/dev/null | openssl x509 -noout -text | grep DNS:
```

# project
```sh
cd project
git init
git remote add origin https://project:glpat-kesdgfmV139azwSUGNRB@gitlab/root/project.git
GIT_SSL_NO_VERIFY=1 git push --set-upstream origin master
```
