
![](https://img.shields.io/badge/Microverse-blueviolet)
# The CSPM A project Management tool for Craft Silicon

> 

## Link
``

``
## Video link



## ERD

![ERD](https://user-images.githubusercontent.com/37341054/139593013-3b3b3b7b-1b7b-4b7b-8b7b-3b7b3b7b3b7b.png)

### Cloning the project

git clone https://github.com/ger619/CSPM.git <Your-Build-Directory>
``` 
- cd CSPM

- ./bin/dev
```


## Built with
- Ruby 3.3.5 on Rails 7.2.1
- PostgreSQL 16

## Prerequisites

Vscode or RubyMine
Setup




## Install
    Ruby
    Rails
    PostgreSql
    Tailwindcss

### Development Database

```
# Sign into posgresql
su - postgres

# Create user
create user 'user_name' with encrypted password 'mypassword'

# Load the schema
rails db:schema:load

#----- If you want prefer this approach
# Create the database
rake db:create

# Create database Migration
rails db:migrate
```

### Run

```
bundle install

./bin/dev
```

## Run tests
```
bundle install
rspec
```

## Authors

👤 **AbolGer**

- GitHub: [@ger619](https://github.com/ger619)
- Twitter: [@ger_abol]()
- LinkedIn: [David Ger](https://linkedin.com/in/david-ger-426b4576)


## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

Feel free to check the [issues page](https://github.com/ger619/CSPM/issues).

## Design

Original design idea by [Unk](Link) on Behance.
The Creative Commons license of the design requires that you give appropriate credit to the author.
## Show your support

Give a ⭐️ if you like this project!

## 📝 License

This project is [MIT](./MIT.md) licensed.
