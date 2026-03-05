<div align="center">
  <img src="public/images/github-logo.png" width="150" height="150" align="left">
  <div align="left">
    <h3>FluffFox</h3>
    <a href="https://github.com/NixtenKame/FluffFoxng/releases">
      <img src="https://img.shields.io/github/v/release/NixtenKame/FluffFoxng?label=version&style=flat-square" alt="Releases" />
    </a><br />
    <a href="https://github.com/NixtenKame/FluffFoxng/issues">
      <img src="https://img.shields.io/github/issues/NixtenKame/FluffFoxng?label=open%20issues&style=flat-square" alt="Issues" />
    </a><br />
    <a href="https://github.com/NixtenKame/FluffFoxng/pulls">
      <img src="https://img.shields.io/github/issues-pr/NixtenKame/FluffFoxng?style=flat-square" alt="Pull Requests" />
    </a><br />
    <a href="https://github.com/NixtenKame/FluffFoxng/commits/main/">
      <img src="https://img.shields.io/github/check-runs/NixtenKame/FluffFoxng/main?style=flat-square" alt="GitHub branch check runs" />
    </a><br />
  </div>
</div>
<br />


## Installation (Easy mode - For development environments)

### Prerequisites

 * Latest version of Docker ([download](https://docs.docker.com/get-docker)).
 * Latest version of Docker Compose ([download](https://docs.docker.com/compose/install))
 * Git ([download](https://git-scm.com/downloads))
 
 If you are on Windows Docker Compose is already included, you do not need to install it yourself.
 If you are on Linux/MacOS you can probably use your package manager.

### Installation

1. Download and install the [prerequisites](#prerequisites).
1. Clone the repo with `git clone https://github.com/NixtenKame/FluffFoxng.git`.
1. `cd` into the repo.
1. Copy the sample environment file with `cp .env.sample .env`.
1. WSL Only: Run the following commands:
    ```
    git config core.fileMode false
    cp -ru hooks/ .git
    ```
    This will resolve permission issues, and set up a hook that will reset file permissions to what they are supposed to be in the future.  
    If you are not using WSL, this is likely not a problem for you.
1. Run the following commands:
    ```
    docker compose run --rm FluffFox /app/bin/setup
    docker compose up
    ```
    After running the commands once only `docker compose up` is needed to bring up the containers.
1. To confirm the installation worked, open the web browser of your choice and enter `https://localhost:3000` into the address bar and see if the website loads correctly. (You may need to accept a self-signed certificate warning in development.) An admin account has been created automatically, the username and password are `admin` and `p!nkf0xp@w` respectively.
1. By default, the site will lack any content. For testing purposes, you can generate some using the following command:
    ```
    docker exec -it FluffFoxng-FluffFox-1 /app/bin/populate
    ```
    The command can be run multiple times to generate more content.  
    Environmental variables are available to customize what kind of content is generated.

Note: When gems or js packages are updated you need to execute `docker compose build` to reflect them in the container.

### Local DText gem

You may want to test changes made to the [DText gem](https://github.com/FluffFoxng/dtext) on a local instance.
You are recommended to reconsider and rethink your life choices.

If you are sure that you want to do this, follow these steps.

1. Clone the repo into a `vendor` directory. Example: `~/FluffFoxng/vendor/dtext/`.
   1. `cd ~/FluffFoxng`
   2. `mkdir vendor && cd vendor`
   3. `git clone https://github.com/e621ng/dtext.git` (substitute your local fork as needed)
2. Rebuild the container
   1. `cd ~/FluffFoxng`
   2. `docker compose build --no-cache`
3. Reset the Gemfile.lock: `git checkout HEAD -- Gemfile.lock`  
  This is not required, but it will prevent you from accidentally committing bad changes.
4. Set `LOCAL_DTEXT=true` in the `.env` file.

At this point, the DText repository is set up.
It will be automatically compiled whenever the docker container is started.

It is recommended to set `LOCAL_DTEXT` to `false` whenever you are not actively working on anything related to the DText repo, and then rebuild the container.

### Development environment

This repo provides a Dev Container configuration. You can use something like the [Dev Container extension for VSCode](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) to make use of it. Simply install it, open the folder in VSCode, and click the button in the bottom right to open the folder in the Dev Container.

#### <a id="docker-troubleshooting"></a>I followed the above instructions but it doesn't work, what should I do?

Try this:

1. `docker compose down -v` to remove all volumes.
1. `docker compose build --no-cache` to rebuild the image from scratch.
1. Follow the [instructions](#installation) starting from step 5.

#### <a id="windows-executable-bit"></a>Why are there a bunch of changes I can't revert?

You're most likely using Windows. Give this a shot, it tells Git to stop tracking file mode changes:

`git config core.fileMode false`

#### <a id="development-tools"></a>Things to aid you during development

`docker compose run --rm tests` to execute the test suite.

`docker compose run --rm rubocop` to run the linter.

The postgres server accepts outside connections which you can use to access it with a local client. Use `localhost:34517` to connect to a database named `FluffFox_development` with the user `FluffFox`. Leave the password blank, anything will work.

#### Truenas / Local Server Installation

If you decide to deploy this docker image to an external / local server, you do need to remember to change the DANBOORU_HOST variable in the docker-compose.yml file to the IP of your server. Otherwise, you will not be able to access it, or the image links will be broken. 

Specifically for Truenas/NAS boxes users: you need to use the shell itself to set the repo up, you can then manage the images/variable/config with Portainer/Dockge after it's set up.

## Production Setup

Installation follows the same steps as the docker compose file. Ubuntu 20.04 is the current installation target.
There is no script that performs these steps for you, as you need to split them up to match your infrastructure.
Running a single machine install in production is possible, but is likely to be somewhat sluggish due to contention in disk between postgresql and opensearch.
Minimum RAM is 4GB. You will need to adjust values in config files to match how much RAM is available.
If you are targeting more than a hundred thousand posts and reasonable user volumes, you probably want to procure yourself a database server. See tuning guides for postgresql and opensearch for help planning these requirements.

### Production Troubleshooting

These instructions won't work for everyone. If your setup is not
working, here are the steps I usually recommend to people:

1) Test the database. Make sure you can connect to it using psql. Make
sure the tables exist. If this fails, you need to work on correctly
installing PostgreSQL, importing the initial schema, and running the
migrations.

2) Test the Rails database connection by using rails console. Run
Post.count to make sure Rails can connect to the database. If this
fails, you need to make sure your Danbooru configuration files are
correct.

3) Test Nginx to make sure it's working correctly.  You may need to
debug your Nginx configuration file.

4) Check all log files.

## Technology I Use

1)  **Traffic RRD Tool:** I use quite a few RRD tools; they all function
    the same. I will list them down below.

-   Cacti
-   Zabbix

2)  **Server Infrastructure:** I use cloud computing with AWS on an EC2
    `t3a.xlarge` server. You can do the same, but I'd recommend running
    it on a local server, as AWS **CAN** get a little pricey if you
    leave it on 24/7. And yes, a local server is way more pricey, but if
    you have an old computer with 4 cores and 8GB of RAM with great
    bandwidth, you should be good.

3)  **Domain Registrar:** I've been using a DDNS (Dynamic Domain Name
    System) hosted by No-IP, which can be useful if your ISP doesn't
    allow static IPs. Even though I use an Elastic IP on AWS, I still
    like using the DDNS service because it's completely free. You just
    have to make sure to confirm your domain name every month, which can
    be a little annoying, but it's easy to set up. All you have to do is
    tell No-IP to point to your public IP and you're done. **THAT'S
    IT.** You can register a domain name for free at
    [noip.com](https://www.noip.com/).

4)  **Operating System:** I use Ubuntu 24.04.4 LTS. You **CAN** use
    Ubuntu Server, and it would probably be better than using a
    consumer-grade version of Ubuntu. I just use the consumer-grade
    version because I don't think AWS allows Ubuntu Server, but I could
    be wrong.

5)  **Storage:** For a starter, I'm using a 256GB virtual disk with AWS.
    Depending on how you set up the EC2 server and what resources you're
    using will determine how much money you will be spending on the
    server, as well as how long the server stays up.

6)  **Reverse Proxy:** I'm just listing this because why not, though if
    you already did a deep read on the source code and you know exactly
    how this works, then you can ignore this. I'm just using the Nginx
    reverse proxy, as that's the web server this whole website runs on
    like any other booru website.

7)  **Fonts:** I use Font Awesome, but don't worry about setting up the
    Font Awesome API, as the fonts and logos are being hosted locally.

8)  **Text Editor:** For the production version of this source code, I'm
    using the local DText fork from the [e621ng Source
    Code](https://github.com/e621ng/e621ng/ "Almost all credit goes to Dragon Fruit Ventures LLC. as this source code was NOT modified like crazy").
    You can use the remote DText from e621ng, as I'm still working on
    modifying the DText source code.

9)  **Analytics:** I use a few analytics softwares like Google Tag
    Manager, Google Analytics, and PostHog. You can obtain your API keys
    if you like, but they're not required---only required if you're
    using this source code for production use.

I think the rest is pretty obvious. It's coded in Ruby and Ruby on Rails
with a touch of different languages like Vue.js and Sass for the style
sheets. Now, I was a little confused about what to modify at first, so
I'll help you in the next paragraph.

------------------------------------------------------------------------

## Locations and What They Do

-   The first one, probably the most important if you want to view where
    the webpages are displayed. You can go there in

```
    app/views
```

Within that directory, you will find a bunch of folders that correspond
to the webpage. For example, if you want to look at the webpage for the
posts page, you can go there at

```
    app/views/index.html.erb
```

Ruby on Rails uses the `.erb` file extension for the framework. I will
warn you that these files are super small, so you might have to dig
around to find what you're looking for.

-   Style sheets are weird too, because instead of using CSS, it uses
    SCSS for compression. On GitHub, those files can be found in

```
    app/javascript/src/styles/
```

Why they're in the JavaScript folder, I have no clue. That's just how
they built the source code. Wouldn't it be better if it was like
`app/styles/src/`? lol

-   Controllers are found in

```
    app/controllers
```

These files are what do the backend scripting and other database
scripting.

-   Static front-end pages can be found in the

```
    public
```

folder, and it's where the compiled Vite files are stored, along with
icons and error pages.

------------------------------------------------------------------------

### Conclusion

Almost all files you are looking for for the front-end scripting are
located in the `app` folder.

If you want more information, you can contact me at
<nixtenkame@gmail.com>. If I'm unavailable, you can use AI or some other
SDK built into Visual Studio Code and have it scan everything in the
source code and break it down for you.
