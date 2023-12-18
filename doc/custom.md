# Exemples de personnalisation

## Création d'un paquet debinst restreint
```sh
cp -a buildpackage-op-2min buildpackage-op-spam
cp -a simplecdd-op-2min simplecdd-op-spam
mkdir install-pr-spam
ln -s ~/install/debinst/install-pr-spam ~/install/spam
cd install-pr-spam
ln -s ../buildpackage-pr-spam/list.txt
cp ../0install.sh .  # or link
cp ../install-op-/install-*-res.sh .  # or link
```

## Récupération d'un dépôt git
```sh
untar $name-$branch.tgz || gitClone git@exemple.org:dir/$name.git $branch || return 1
```
