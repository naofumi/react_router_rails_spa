# Integrating Ruby on Rails with Modern SPAs

## TL;DR;

Integrating React onto a Ruby on Rails application is unnecessarily challenging.
Why do we have to install jsbundling-rails, install multiple packages, configure propshaft, create an ERB endpoint, etc.? 
Why can't we just run `rails new`, install a single gem and instantly have a state-of-the-art React setup?

This article introduces the [react_router_rails_spa gem](https://github.com/naofumi/react_router_rails_spa),
which allows you to integrate a React Router SPA framework application into your existing Ruby on Rails project.
It aims
to be an ["omakase"](https://dhh.dk/2012/rails-is-omakase.html) Rails setup
that rivals Next.js for getting up to speed fast.

To jump to the installation steps, go to the "Steps to Integrate React Router into your Rails Application" section.
Installation is quite simple.

## Who is this for?

The react_router_rails_spa gem was designed for the following situations.

### You want to create a web application with a React frontend and a Rails backend.

* You want a simple setup that is ["omakase"](https://dhh.dk/2012/rails-is-omakase.html). You don't want to install packages and configure them on the React side. You don't want to manually add routes and controllers on the Rails side. Everything should be a single gem and a single command.
* You want something that is easy to deploy, and cost-effective. You don't want to worry about being charged for the extra server.
* You don't need SEO for the React pages. 
* If SEO is necessary, you can just serve ERB pages or static HTML files. 

### You are considering Next.js, but you do not need SSR nor RSCs. You are only considering Next.js because it is easy to set up.

* You're only using Next.js because you thought it was ["omakase"](https://dhh.dk/2012/rails-is-omakase.html). It was at least extremely easy to set up on your local machine. Now you've found that Rails integration is harder than you bargained for, especially around authentication schemes and production deployment, domains and CORS settings, etc. You want something simpler from `rails new` to `kamal deploy`.
* You are worried about deployment. Specifically, you are not happy with Vercel pricing or the extra cost of an additional AWS ECS instance to host Next.js.

The react_router_rails_spa gem satisfies the above requirements and more.
It will give you an ["omakase"](https://dhh.dk/2012/rails-is-omakase.html) Modern React SPA with a single command.

### You want to use React because you believe you can create better UIs

* You're using React because you think you can create a better UI/UX compared to Hotwire (I actually think that this is untrue and Hotwire can create great UI/UXs, but that's a different discussion)
* You want to use cutting-edge React capabilities like code-splitting, loader-based data fetching and more. You don't want to create a slow, bloated, legacy React app.

## Who is this NOT for?

### You want to embedd some React components on top of your ERB-rendered pages

This was [the original way that React was used](https://react.dev/learn/add-react-to-an-existing-project#using-react-for-a-part-of-your-existing-page).
React was built for this, and it's generally much simpler to set up than a multi-page SPA.
The current gem does not help you with this.
If you wish to take this approach,
you can build your own system or use Gems like [react-rails](https://github.com/reactjs/react-rails) and  [turbo-mount](https://github.com/skryukov/turbo-mount).
Turbo Mount uses Stimulus to mount components, and is more robust if you are using Hotwire in your ERB views.

## How does this compare to [...]?

Compared to gems like [React on Rails](https://github.com/shakacode/react_on_rails) or [Intertia Rails](https://inertia-rails.dev/),
the current gem is just an installer and does virtually nothing to modify or add features to React Router,
the de-facto standard router library for React.
This ensures that frontend developers will feel right at home.
It also means that you can easily understand how it works, and can customize accordingly.

## Background

On February 14th, 2025,
the React team published a blog post
titled [Sunsetting Create React App](https://react.dev/blog/2025/02/14/sunsetting-create-react-app). They strongly recommended
that **developers should now use an SPA framework instead**.

Importantly, and often lost in the public discourse, they were **NOT** recommending an **SSR** framework.
Instead, they were advocating for creating SPAs with [**SPA** frameworks](https://react.dev/blog/2025/02/14/sunsetting-create-react-app#how-to-migrate-to-a-framework)
that could be deployed on a CDN, a static hosting service, or the `public` folder of a Ruby on Rails application.

In the following, I will call SPAs built with an SPA framework, **"Modern React SPAs"**
to highlight that this is the current officially recommended approach.
To contrast, I will call the ones that the React team is actively discouraging, **"Legacy React SPAs"**.

> **"I have no interest nor use for SSR!
I don't need SEO.
> An SPA is all that I need.
> Instead of Create React App, I'll just use Vite!"**

This was the most common response to the blog post.
However IMO, it misses the point that the authors were repeatedly trying to make.

The React team is strongly recommending that **even if you only need an SPA, you should be creating a Modern SPA**.
[They carefully go through some of the features](https://react.dev/learn/build-a-react-app-from-scratch) like code-splitting
and loader-based routing
that you will need to add if you are building a state-of-the-art React SPA from scratch.
These features are often challenging and require expertise to correctly implement,
but are essential for modern React applications.

Without these features, your React SPA is a Legacy SPA.
It will suffer from the same performance issues that plagued old SPAs a decade ago –
namely huge initial bundle size, data-fetch waterfalls, flickering, and very slow load times.

In the above article,
the React team went out of its way
to tell us
that we should not simply replace the deprecated Create React App with a newer but nonetheless still architecturally Legacy SPA.
Instead, they strongly urge us to embrace Modern React SPAs and avoid these issues.

I should note that Vite is essentially a bundler and a development server, with a plugin system that allows us to easily install various packages.
It is agnostic to the Legacy vs. Modern SPA debate.
You can build a Legacy SPA using Vite, and you can also create a Modern SPA.
Vite does not care either way, and the installer command `npm create vite@latest` gives you both templates.

> **"I want to integrate my React app with a Ruby on Rails backend. I'll just add a `javascript_include_tag` to my bootstrap ERB template. That will load React just fine!"**

This is also a common response from people who prefer a no-fuss solution for Rails.
However, note that this is exactly the approach that the React team strongly discourages.
The above solution is a Legacy SPA and will suffer from the same legacy issues.

Instead, the React team is recommending that you integrate a Modern SPA framework using ...

Well, actually, they don't have a concrete recommendation yet for Rails.
As far as I know, nothing currently exists to easily integrate a Modern SPA with Rails.

I hope to address this with this [react_router_rails_spa gem](https://github.com/naofumi/react_router_rails_spa).

## Why we need a different approach for Rails integration

Historically,
the way to integrate React with Ruby on Rails was to create an ERB endpoint that served as the initial HTML
(the bootstrap HTML) for React. 
This ERB template would have either a `javascript_include_tag` (jsbundling-rails) or a
`javascript_pack_tag` (webpacker) to load the React application build artifact.
Newer gems like [Vite Rails](https://vite-ruby.netlify.app/guide/rails.html#tag-helpers-🏷) have also adopted the same approach.

However, this is exactly what the React team is discouraging, and it seems unwise to continue down this path.

The problem is that Modern SPAs build their own bootstrap HTML templates with SSG
(the first HTML that the browser loads).
Modern SPA frameworks are not just JavaScript.
Instead, the bootstrap HTML and the JavaScript are tightly integrated.

Therefore, to take advantage of Modern SPA features,
Rails has
to give up
on generating its own bootstrap HTML from an ERB template with an embedded `javascript_include_tag`.
Instead, we have to take the bootstrap HTML generated by the SPA framework, and wrap Rails around this.

This is how the react_router_rails_spa gem works.

## Outline of how the gem works

It is important to note that the [react_router_rails_spa gem](https://github.com/naofumi/react_router_rails_spa) does nothing more than a stock React Router installation with some custom configuration,
paired with the generation of a single Rails controller.

**There is very little custom code, and this is actually a huge advantage**.
This is a very thin wrapper around the official React Router installer and resilient against future changes.
If you wish, you can easily update and customize your NPM packages independently of this gem. The generated code is also heavily commented
to help you understand the internals for yourself.

### React Router

We install and use React Router in framework mode, [configured to generate an SPA build](https://reactrouter.com/how-to/spa).
This will build static files that can be served from any static hosting provider, including the `public` folder in Rails.

One of these static files is the bootstrap HTML template (the root `index.html` file).
We change the name of this file so that it will not be directly served from the `public` folder.
Instead,
we use a dedicated Rails controller to add Rails-generated HTTP headers and cookies
and serve the file as the response body.

After building, these static files will be transferred to the Rails `public` folder from which they can be deployed like any other static asset.

### Rails routes.rb and the ReactController

We generate a `ReactController` that serves the bootstrap HTML template.
The body of the response is the exact contents of the React Router-generated `index.html` file, but
by passing it through the `ReactController`,
we can customize the headers and add session-specific information as cookies.

For example, `ReactController`
includes  the `ReactRouterRailsSpa::CsrfCookieEnabled` module
which sends session-specific CSRF tokens via cookies to integrate Rails'
CSRF protection with React.

`ReactController` will also add session cookies so that you can take advantage of session information from the bootstrap HTML file onwards.

Finally, the `ReactController` allows you to set cache headers separately from assets served directly from the `assets` folder.

Rails uses the [ActionDispatch::Static middleware](https://api.rubyonrails.org/classes/ActionDispatch/Static.html)
to serve assets from the `public` folder,
and this sets the HTTP caching headers aggressively to allow extensive caching for long periods of time.
While this is great for JavaScript, CSS and image assets,
this is usually undesirable for HTML files since we cannot attach cache-busting digests to them.
Serving the bootstrap HTML template through `ReactController` allows us
to easily change the cache headers to values that are suitable for HTML responses.
Currently, the [react_router_rails_spa gem](https://github.com/naofumi/react_router_rails_spa) uses the same cache headers as other ERB files,
but this can be customized in the controller. 

Another way to look at this integration is like this;

* The traditional approach taken by webpack, esbuild and vite-rails, is to communicate between the React application and Rails via a Rails generated ERB bootstrap HTML. For example, Rails-generated CSRF tokens were provided as `meta` tags embedded in HTML.
* The current approach is to use the React Router generated bootstrap HTML and to add Rails integration through HTTP headers (including cookies) only. Rails doesn't touch this file and leaves it as is. That's why this gem sends Rails-generated CSRF tokens to the React application using cookies – we don't want to modify the HTML itself.

### Rake files for automation

We provide rake tasks for starting up the development server and building the React Router application.

Note that the build task is attached to the `assets:precompile` task.
This means
that you do not need
to add extra configuration to your CI/CD scripts
to build the React Router app since it should normally call this task already.

If your CI/CD already installs Node (which is required for building), then you probably won't have to touch your CI/CD scripts at all.

### Additional React Router and Vite Configuration

We currently serve the React application from the `/react/*` paths.
All other paths are handled by Rails.
The current gem adds minor configurations for this.
If you want a different setup, you can change the configurations.

Note that configurations for the Vite development server are tricky.
We have provided settings
to compensate for the fact that the development server runs on port 5173 while the Rails application runs on port 3000.
However, this will not allow you to test integration between Rails and React.

* The React app runs on port 5173 while the ERB files are on port 3000. Links between the two will not work on the development server, even if they are fine in production.
* The React app running on the development server will not bootstrap from the Ruby on Rails endpoint on the `ReactController#show` action. Instead, the development server will directly serve the React Router generated bootstrap HTML. This means that the bootstrap file will not contain Rails integrations. This is only an issue on the development server and not in production.

As a solution, you can use the development server with HMR for small fixes, but for larger changes,
you will need to use a "preview" build.
You should also always check with a "preview" build before deploying to production.

We provide a rake task for building a "preview".

```shell
bin/rails react_router:preview
```

## Demo and Source code

* I have a [demo application running on Kamal on a VPS server](https://rrrails.castle104.com/react/). It has simple, session-based authentication and basic CRUD. Mutations are secured by integration with Rails CSRF protection.
* In the demo application, I have intentionally added a 0.5 to 1.5-second delay on all server requests. Even the most bloated and inefficient web technologies will look great on a high-performance device with a fast network. Unless your demo intentionally simulates non-ideal situations, it is meaningless.
* The source-code for this demo application is [available on GitHub](https://github.com/naofumi/react-router-vite-rails).

The source code is heavily commented. I recommend that you read through it to understand the setup in more detail.

## Using the gem

### Install Ruby on Rails

This gem works with a pre-existing installation of Rails. Create a new Rails application if you haven't already.

```shell
rails new [project name]
```

Note that this gem works even with a no-build Rails setup (which is the Rails default).
However, you will need Node.js in your CI/CD for deployment.
If you are unsure how to do this,
we recommend that you generate a new Rails application with jsbundling-rails pre-installed.
This will create a ready-made Dockerfile that installs Node.js.
(This gem won't use esbuild. We're only doing this for Node.js.)

```shell
rails new [project name] --javascript esbuild
```

### Install the `react_router_rails_spa` gem

Add the following line to your `Gemfile`.

```ruby
gem "react_router_rails_spa"
```

Install the gem

```shell
bundle install
```

We recommend committing your changes at this point before the following generator adds and modifies your files.

Run the generator

```shell
bin/rails generate react_router_rails_spa:install
```

This will install the latest version of React Router
and generate the routes and all the necessary files and configurations.

### Run the development server

Run the following command to start the development server. This comes with HMR (Hot Module Replacement).

```shell
bin/rails react_router:dev
```

Point your browser to http://localhost:5173/react/ to see the welcome page.

### Build the React Router application

Run the following command to build the React Router application
and store the static files into the Rails `public` directory.

```shell
bin/rails react_router:build
```

Start your Rails application if it is not already running.

Point your browser to http://localhost:3000/react/ to see the welcome page.

This command is also aliased as `preview`.

```shell
bin/rails react_router:preview
```

### Read the added code

I have added numerous comments to the code generated by this gem. Please read it to understand how the integration works.

