#!/bin/bash -xe

mkdir -p -m 700 ~/.ssh
cat > ~/.ssh/config << EOF
Host github.com
  Port 22
  User ${GITHUB_USER_NAME}
Host *
  StrictHostKeyChecking no
EOF

# Setup git
git config push.default current
git config user.name "CircleCI"
git config user.email ${EMAIL}

bundle exec rake generate_ical

changed_num=`git --no-pager diff --unified=0 -- docs/*.ics | grep -v "@@" | grep -v " a/" | grep -v " b/" | grep -v "index " | wc -l`

if [ $changed_num == "0" ]; then
  echo "Not changed"
  exit 0
fi

git --no-pager diff
git add docs/*.ics
git commit -am "Update from CircleCI [ci skip]"
git push origin
