# Commitizen

[Commitizen](https://commitizen-tools.github.io/) is a CLI tool for standardised commiting messages.

The CLI tools and an adapter (the `cz-conventional-changelog` which follows AngularJS standard for commit messages) need to be installed globally 
using `npm`.

```bash
npm i -g commitizen cz-conventional-changelog
```

The file `.czrc` defines that all global calls to `git cz` should use the `cz-conventional-changelog` adapter.

For more settings see :link: [Commitizen's GitHub](https://github.com/commitizen/cz-cli)
