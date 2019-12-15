# Evolution Challenge

Coding Challenge for Evolution Virtual

## Getting Started

**Client Side Prerequisites**

* Most recent version of Chrome or Firefox
* Node v13 or higher

**Server-Side Prerequisites**

* Python 3.6 or higher
* `pip`
* PostgreSQL 10 or higher
* .pgpass set up to allow login without explicit username/password to an account with permissions to create a database

### Install and Run Client

```bash
    $ cd evolution-challenge
    $ npm install yarn
    $ yarn install
    $ yarn start
```

Navigate to [http://127.0.0.1:3000]

The client will work without the server.  However, to load data from the server (using the button at the top of the page) instead of in the client, a) the server must be running, and b) due to browser security defaults, the client must use `127.0.0.1` instead of `localhost` as the hostname.

### Install and Run Server

```bash
    $ createdb evolution_challenge_nkm
    $ cd evolution-challenge

    # If you use `pipenv`
    $ pipenv install
    $ pipenv shell

    # without `pipenv`
    $ virtualenv venv
    $ . venv/bin/activate
    $ pip install -r requirements.txt

    # Create the database schema
    $ python manage.py migrate
    # Note that running `psql evolution_challenge_nkm < install.sql`
    # will create the schema but not load the metadata that Django needs to
    # operate correctly

    # Import data
    $ python manage.py load_scores public/2016-2017.json public/2015-2016.json

    # start server
    $ python manage.py runserver
```

Server will run on localhost:8000.  The API can be accessed as follows

* [http://localhost:8000/summary?season_id=1]: view all team stats for the first season loaded
* [http://localhost:8000/summary?season_id=2&team_code=CHE]: view stats for team with code "CHE" for the second season loaded

Bonus: Django comes with an easy-to-configure admin panel that can be useful for checking loaded data.  To access it, you must create a superuser:

```bash
    $ python manage.py createsuperuser
    # follow prompts to configure username, email, password

    $ python manage.py runserver
```

Access the admin site at [http://localhost:8000/admin/] with the superuser's credentials.


------------------------------------

## Discussion

Some of the decisions made in building this app, and alternatives considered.

### Using React

A reactive framework is the modern way to build applications and saves a lot of mental overhead in reasoning about state.

I have a slight preference for the ergonomics of Vue over React.  But I've used React more recently and am slightly rusty on Vue.  Additionally, React is more broadly known than Vue.  I have not used Angular in several years, nor any of the newer frameworks, but there are several additional options that might have been valid choices.

For this exercise, I selected React in the interest of time and of building something easily comprehensible to the reviewer.

### Grid Controls vs. Table

Before beginning this exercise, I investigated a few open source options for grid controls.  After growing frustrated with poor documentation and low markup configurability, I chose to use a plain HTML table in the interest of time and sanity.  This is the simplest choice for an application where the table content need not be editable.

For a production application that requires data be editable in the browser, I would put more effort into getting an existing grid control to work, or perhaps even invest in one that is commercially licensed for the sake of stability and support.

### Using Redux

Redux is a little bit overkill for an application this size.  I ended up using it anyway because it's so much a part of the idiom of React apps.

### Denormalizing data on client

Recaulculating the total stats is an expensive operation.  The raw data could have been stored in Redux and the totals recalculated for every re-draw. But that seemed unnecessary given that the challenge has no use for the raw data.  It made more sense to load and calculate totals once upon load.


### Using Python

Python is my strongest language and the one in which I'm most familiar with the ecosystem and available frameworks.  I seriously considered building the server application using Javascript/Node.js, but ultimately chose to use Python in the interest of time.


### Using Django

The server portion of the application could have been build using raw SQL or piecing together standalone components such as Flask or SQLAlchemy.  Ultimately I chose Django because it is what I'm most fluent in -- again, in the interest of time.

Django also offers a few niceties that ended up being helpful for the challenge: including a database migration framework that makes it easy to iterate on schema design, and an "almost-free" admin panel for browsing and verifying data.

### Normalized database

The server side database could have been denormalized as was done with the client data.  I didn't do this for a couple of reasons:

1. Working out how to represent the data in a normalized manner for maximum queryability and yet pull all calculated data in a single query seemed like a fun challenge.
2. The challenge description mentioned additional data such as goal scorers (not available in the initial data set), suggesting a likely future product need for the denormalized data.


### Views but not materialized views

Calculating the stats turned out to require a fairly complex query.  Significant additional complexity was introduced by the rank and eligibility calculations.  Thankfully, Postgres' features enabled these to be less complex than they might have been in MySQL, SQLite, etc.

Encapsulating that complexity in a view enabled us to use an "unmanaged" Django ORM model class to represent it in the application.  This significantly simplified building a REST endpoint on top of it.  In a larger application, it would also open up this data to being more easily integrated with more of the included features of Django or with other parts of the Django ecosystem.

Using a vanilla view instead of a materialized view means that the database performs the expensive joins and aggregate calculations for every query.  This is viable given the small size of our data set and low traffic.

It might become prohibitively expensive for a larger data set or more heavily used site. In that case, a materialized view -- essentially cached pre-calculated data -- would save a lot of database load.  The trade-off would be having to make sure the view was refreshed any time data was updated, or choosing a schedule on which to refresh it.

### Not using Django-Rest-Framework

Django-Rest-Framework (DRF) is a de facto standard in the Django ecosystem for building RESTful APIs.  I chose not to use it because it seemed like overkill for a single endpoint, and because I find its design frustrating.

For a larger application or one intended to be maintained by multiple developers, however, I would likely have used DRF for purposes of consistency and because develoeprs familiar with Django are likely to also be familiar with DRF.

One downside of this choice is that the API does not provide references to related objects as it might in a strict interpretation of the REST standard.

### Other potential areas for polish

* Endpoints to show what seasons and teams are available could be built
* Import info about leagues for each team

### Generating schema from Django models and extracting SQL using pg_dump

Is that cheating?  There were no instructions to that effect.  Seemed far more efficient than writing table definitions by hand, which I could have done but would have taken hours.
