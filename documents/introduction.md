# Integrating Ruby on Rails with Modern SPAs

## TL;DR;

Integrating React onto a Ruby on Rails application is unnecessarily challenging. We have to install jsbundling-rails, install multiple packages, configure propshaft, create an ERB endpoint, etc.

Why can't we just run `rails new`, install a single gem, and instantly have a state-of-the-art React setup with client-side routing, code-splitting, and effective data-loading patterns built-in?

This article introduces the [react_router_rails_spa gem](https://github.com/naofumi/react_router_rails_spa), which integrates a React Router SPA framework application into your existing Ruby on Rails project. With just a few commands, you will have a fully functioning scaffold on which to build your React app.

To jump to the installation steps, go to the ["Using the gem" section](#using-the-gem).

## Who is this for?

If any of the following describes yourself, then this gem might be for you.

### You want to create an SPA with a React frontend and a Rails backend.

* You want a simple setup that is ["omakase"](https://dhh.dk/2012/rails-is-omakase.html). You don't want to install packages and configure them on the React side. On the Rails side, you don't want to manually add routes and controllers. Everything should be a single gem and a single command.
* You want something that is easy to deploy, and cost-effective. You don't want to pay for an extra server that you don't strictly need.
* You don't need SEO for the React pages.
* If SEO is necessary, you can just serve ERB pages or static HTML files.

### You tried Next.js, but you did not really need SSR nor RSCs. You were only interested in Next.js because you thought it was easy.

* You're only using Next.js because you thought it was ["omakase"](https://dhh.dk/2012/rails-is-omakase.html) and simple to set up.
* After a while, you've found that integrating the Next.js server and the Rails server is harder than you bargained for. You've had headaches around authentication schemes, cross-domains, subdomains, CORS settings, samesite cookies, CSRF mitigation, and reverse proxies, etc. You've realized that running separate frontend and backend servers is hard.
* You are not happy with the extra money you have to pay to Next.js.

The [react_router_rails_spa gem](https://github.com/naofumi/react_router_rails_spa) gives you the simplicity of an opinionated SPA framework, without the complexity of a mulit-server setup.

### You want to use cutting-edge React

* You want to use cutting-edge React capabilities like code-splitting, loader-based data fetching and more, but you're not sure how to [set this up from scratch](https://react.dev/learn/build-a-react-app-from-scratch).
* You don't want to create a slow, bloated, legacy React app.

## Who is this NOT for?

### You want to embed some React components on top of your ERB-rendered pages

This is [how React was originally used](https://react.dev/learn/add-react-to-an-existing-project#using-react-for-a-part-of-your-existing-page). React was built for this, and it's generally much simpler to set up than a multi-page SPA.

The current gem does not help you with this however since it is designed for SPA frameworks. If you wish to take this approach, you can build your own system or use Gems like [react-rails](https://github.com/reactjs/react-rails) and  [turbo-mount](https://github.com/skryukov/turbo-mount). Turbo Mount uses Stimulus to mount components, and is more robust if you are using Hotwire in your ERB views.

## How does this compare to [...]?

Compared to gems like [React on Rails](https://github.com/shakacode/react_on_rails) or [Inertia Rails](https://inertia-rails.dev/), the current gem is just an installer and does virtually nothing to modify or add features to React Router. This is a great advantage and ensures that frontend developers will feel right at home.

It also means that you can easily understand how it works. You can customize accordingly.

## Background

On February 14th, 2025, the React team published a blog post
titled [Sunsetting Create React App](https://react.dev/blog/2025/02/14/sunsetting-create-react-app). They strongly recommended that **developers should now use an SPA framework instead**.

Importantly, and often lost in the public discourse, they were **NOT** recommending an **SSR** framework. Instead, they were advocating for creating SPAs with [**SPA** frameworks](https://react.dev/blog/2025/02/14/sunsetting-create-react-app#how-to-migrate-to-a-framework) that could be deployed on a CDN, a static hosting service, or the `public` folder of a Ruby on Rails application.

In the following, we will call SPAs built with an SPA framework, **"Modern React SPAs"** to highlight that this is the current officially recommended approach. To contrast, we will call the ones that the React team is actively discouraging, **"Legacy React SPAs"**.

> **"I have no interest nor use for SSR! I don't need SEO. An SPA is all that I need.**
>
> **Instead of Create React App, I'll just use Vite!"**

This was the most common response to the blog post. However IMO, it misses the point that the authors were repeatedly trying to make.

The React team is strongly recommending that **even if you only need an SPA, you should be creating a Modern SPA**. [They carefully go through some of the features](https://react.dev/learn/build-a-react-app-from-scratch) like code-splitting and loader-based routing that you will need to add if you are building a state-of-the-art React SPA from scratch.

These features are often challenging and require expertise to correctly implement, but are essential for modern React applications.

Without these features, your React SPA is a Legacy SPA. It will suffer from the same performance issues that plagued old SPAs a decade ago – namely huge initial bundle size, data-fetch waterfalls, flickering, and very slow load times.

In the above article, the React team went out of its way to tell us that we should not simply replace the deprecated Create React App with a newer but nonetheless still architecturally Legacy SPA. Instead, they strongly urge us to embrace Modern React SPAs and avoid these issues.

We should note that Vite is essentially a bundler and a development server, with a plugin system that allows us to easily install various packages. Although extremely useful, it is agnostic to the Legacy vs. Modern SPA debate. You can build a Legacy SPA using Vite, and you can also create a Modern SPA. Vite does not care either way, and the installer command `npm create vite@latest` gives you templates for both.

> **"I want to integrate my React app with a Ruby on Rails backend. I'll just add a `javascript_include_tag` to my bootstrap ERB template. That will load React just fine!"**

This is also a common response from people who prefer a no-fuss solution for Rails. However, note that this is exactly the approach that the React team strongly discourages. The above solution is a Legacy SPA and will suffer from the same legacy issues.

Instead, the React team is recommending that you integrate a Modern SPA framework using ...

Well, actually, they don't have a concrete recommendation yet for Rails. As far as we know, nothing currently exists to easily integrate a Modern SPA with Rails.

We hope to address this with this [react_router_rails_spa gem](https://github.com/naofumi/react_router_rails_spa).

## Why we need a different approach for Rails integration

Historically, the way to integrate React with Ruby on Rails was to create an ERB endpoint that served as the initial HTML
(the bootstrap HTML) for React. This ERB template would have either a `javascript_include_tag` (jsbundling-rails) or a `javascript_pack_tag` (webpacker) to load the React application build artifact. Newer gems like [Vite Rails](https://vite-ruby.netlify.app/guide/rails.html#tag-helpers-🏷) have also adopted the same approach.

However, this is exactly what the React team is discouraging, and it seems unwise to continue down this path.

The problem is that Modern SPAs build their own bootstrap HTML templates with SSG (the first HTML that the browser loads).
Modern SPA frameworks are not just JavaScript and instead, the bootstrap HTML and the JavaScript are tightly integrated.

Therefore, to take advantage of Modern SPA features, Rails has to give up on generating its own bootstrap HTML from an ERB template with an embedded `javascript_include_tag`. A better approach is to take the bootstrap HTML generated by the SPA framework, and wrap Rails integration around this.

This is how the react_router_rails_spa gem works.

## Outline of how the gem works

It is important to note that the [react_router_rails_spa gem](https://github.com/naofumi/react_router_rails_spa) is nothing more than a stock React Router installation with some custom configuration, paired with the generation of a single Rails controller.

**There is very little custom code, and this is actually a huge advantage**. This is a very thin wrapper around the official React Router installer and resilient against future changes. If you wish, you can easily update and customise your NPM packages independently of this gem. The generated code is also heavily commented
to help you understand the internals for yourself.

### React Router SPA framework mode

We install and use React Router in SPA framework mode, [configured to generate an SPA build](https://reactrouter.com/how-to/spa).
It is a true SPA and will build static files that can be served from any static hosting provider. These are transferred to the `public` folder in Rails for deployment.

The command for building the react application is integrated into the `rake assets:precompile` command. Therefore, you do not need any additional configuration in your CI/CD scripts.

### Integration with Ruby on Rails through cookies

Previously, you would integrate Ruby on Rails using a bootstrap HTML template generated by Rails using ERB templates. This allowed you, for example, to embed CSRF-mitigation token tags. As mentioned above, this is incompatible with Modern SPA frameworks.

Otherwise, you could build your SPA independently of Rails and send extra requests from the browser to retrieve the CSRF token and other integration information. This requires otherwise unnecessary network requests.

Neither approach is ideal.

Instead, the [react_router_rails_spa gem](https://github.com/naofumi/react_router_rails_spa) sends Rails-generated cookies and/or headers alongside the SPA framework-generated bootstrap HTML file. It give you the best of both worlds.

For example, the `ReactRouterRailsSpa::CsrfCookieEnabled` module
sends session-specific CSRF tokens via cookies to integrate Rails'
CSRF protection with React. The SPA framework-generated HTML is untouched.

### Rake files for automation

We provide rake tasks for starting up the development server and building the React Router application.

Note that the build task is attached to the `assets:precompile` task.
This means that you do not need to add extra configuration to your CI/CD scripts to build the React Router app since it should normally call this task already.

If your CI/CD already installs Node (which is required for building), then you probably won't have to touch your CI/CD scripts at all.

### Additional React Router and Vite Configuration

We currently serve the React application from the `/react/*` paths. All other paths are handled by Rails. The current gem configures this for you. If you want a different setup, you can change the configurations.

## Demo and Source code

* We have a [demo application running on Kamal on a VPS server](https://rrrails.castle104.com/react/). It has simple, session-based authentication and basic CRUD. Mutations are secured by integration with Rails CSRF protection.
* In the demo application, we have intentionally added a 0.5 to 1.5-second random delay on all server requests. Even the most bloated and inefficient web technologies will look great on a high-performance device with a fast network. Unless your demo intentionally simulates non-ideal situations, it is meaningless.
* The source-code for this demo application is [available on GitHub](https://github.com/naofumi/react-router-vite-rails).

The source code is heavily commented. We recommend that you read through it to understand the setup in more detail.

## Using the gem

### Install Ruby on Rails

This gem works with a pre-existing installation of Rails. Create a new Rails application if you haven't already.

```shell
rails new [project name]
```

Note that this gem works even with a no-build Rails setup (which is the Rails default). However, you will need Node.js in your CI/CD for deployment. If you are unsure how to do this, we recommend that you generate a new Rails application with jsbundling-rails pre-installed by using the following installation command.
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

This will install the latest version of React Router and generate the routes and all the necessary files and configurations.

### Run the development server

Run the following command to start the frontend development server with HMR (Hot Module Replacement).

```shell
bin/rails react_router:dev
```

Point your browser to http://localhost:5173/react/ to see the welcome page.

Note that the frontend development server will not truly represent
how the React application and Rails server interact in production. In particular, features that require integration like linking between the React and Rails app may not work. It is important to test with the following preview command before deploying.

### Preview and build the React Router application

Run the following command to build the React Router application
and store the static files into the Rails `public` directory.

```shell
bin/rails react_router:build
```

This command is also aliased as:

```shell
bin/rails react_router:preview
```

Start your Rails application if it is not already running and point your browser to http://localhost:3000/react/ to see the welcome page.

### Read the code

We have added numerous comments to the code generated by this gem. Please read it to understand how the integration works.
