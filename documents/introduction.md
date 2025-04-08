# Integrating Ruby on Rails with Modern SPAs

## TL;DR;

## Who is this for?

The react_router_rails_spa gem was designed for the following situations.

* You want to create a web application with a React frontend and a Rails backend.
  * You are not concerned about SEO for the React pages. If you need SEO, you are willing to create marketing pages with ERB or static HTML files served from the Rails `public` folder
  * You want a simple setup that is easy to build, easy to deploy, and cost-effective. You want it to be as simple as installing a single gem.
* You are considering Next.js, but you do not need SSR or RSCs. You are only considering Next.js because it is easy to set up.
  * You are concerned about deployment. Specifically, you are not happy with Vercel pricing or the extra cost of an additional AWS ECS instance to host Next.js.

In my experience, this covers the majority of Next.js websites in the wild.

In addition to satisfying the above requirements,
the react_router_rails_spa gem will give you a Modern React SPA.

This article describes how the react_router_rails_spa gem works, the history behind Modern React SPAs and what the benefits are.

To jump to the installation steps, go to the "Steps to Intergrate React Router into your Rails Application" section.

## Introduction

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
It will suffer from the same performance issues that plagued old SPAs a decade ago – namely huge initial bundle size, data-fetch waterfalls, and very slow load times.
The React team went out of its way to tell us that we should not replace deprecated Legacy SPAs
(Create React App) with a newer but still Legacy SPA.
Instead, they strongly ask us to embrace Modern React SPAs and solve these issues.

I should note that Vite is essentially a bundler and a development server.
Its plugin system allows us to easily install various packages.
It is agnostic to the Legacy vs. Modern SPA debate.
You can build a Legacy SPA using Vite, and you can also create a Modern SPA using Vite.
The Vite installer command `npm create vite@latest` gives you both templates.

> **"I want to integrate my React app with a Ruby on Rails backend. I'll just add a `javascript_include_tag` to my bootstrap ERB template. That will load React just fine!"**

This is also a common response from people who prefer a no-fuss solution for Rails.
However, note that this is exactly the approach that the React team strongly discourages.
The above solution is a Legacy SPA and will suffer from the same legacy issues.

Instead, the React team is recommending that you integrate a Modern SPA framework using ...

Well, actually, they don't have a concrete recommendation yet for Rails.
As far as I know, nothing currently exists to integrate a Modern SPA with Rails.
This is the deficiency that this article aims to address.

## Are Modern SPAs better?

Before going further, this discussion begs the question – "Are Modern SPAs better than Legacy SPAs?"
Is the React team's insistence on Modern SPAs justified?
To answer this question, it helps to review some history.

Back in the mid-2010s, even when a React application consisted of multiple independent pages,
Legacy React SPAs would load all the code for every page on the first load.
While this was a minor issue for small React apps,
the original React Router enabled developers to create large applications with tens or even hundreds of pages.
The code for all these pages could easily become several megabytes in size,
and since this was all loaded on the first request in a single bundle, initial page loading was very slow.

To address this, you could use `React.lazy()` for code-splitting.
You would manually modify your code so that the modules for each page were loaded on demand.
This allowed you to reduce the size of the initial JavaScript bundle,
but it came with a significant tradeoff – request-waterfalls and slow transitions between pages.

Legacy React apps typically loaded data after component rendering,
often inside a `useEffect()`.
This means that if you clicked a link for a lazy-loaded page,
the browser would first send a request for the page's code,
render that, send a request to the JSON API for the data (inside a `useEffect()`),
and then finally render the full page when the data was received.
Browsers could not do this in parallel because they could not know how to fetch data until the page was rendered.

You were essentially trading the problem
of loading a huge initial bundle with the slow data-fetch waterfall introduced by code-splitting and lazy-loading.

SSR frameworks were developed to solve this problem.
For example, Next.js included a router,
which could closely collaborate with the loader-based data-fetching pattern enforced by `getServerSideProps()`.
They also provided code-splitting by default.

The patterns that emerged were not only useful for SSRs, however.
They could often be used equally effectively for SPAs,
and so SPA frameworks emerged out of SSR framework technologies.
Hence, the back-porting of Remix (SSR) features to React Router (SPA) and the eventual merging of both into onw. 

For SPAs, the fundamental solution to the data-fetch waterfall problem is
to send a request for both the code fragment and the data in parallel, immediately after the link is clicked.
This requires
that the app knows both how to fetch the page's code and how to fetch the page's data before actually rendering the page.
In Modern SPA frameworks, this is possible thanks to close integration of the router and enforcement of the loader pattern.

Furthermore, React Router can automatically split up your code per-route.
You do not have to manually write `React.lazy()` in your code anymore.

So in summary, **yes, Modern SPAs are better than Legacy SPAs**.
They make it easy to write SPAs that did not have the performance foot-guns prevalent in Legacy SPAs.
At the same time, they can still be deployed on a CDN, static hosting, or in the Rails `public` folder.

**The result is simply more performant SPAs with better UX.**

## Why we need a different approach for Rails integration

Historically,
the way to integrate React with Ruby on Rails was to create an ERB endpoint that served as the initial HTML
(the bootstrap HTML) for React. 
This ERB template would have either a `javascript_include_tag` (jsbundling-rails) or a
`javascript_pack_tag` (webpacker) to load the React application build artifact.
Newer gems like [Vite Rails](https://vite-ruby.netlify.app/guide/rails.html#tag-helpers-🏷) adopted the same approach.

However, this is exactly what the React team is discouraging, and it seems unwise to continue down this path.

The problem is that Modern SPAs build their own bootstrap HTML templates with SSG
(the first HTML that the browser loads).
Modern SPA frameworks are not just JavaScript.
Instead, the bootstrap HTML and the JavaScript are tightly integrated.
Therefore, to take advantage of Modern SPA features, Rails has to build upon the SSG-rendered HTML instead of generating its own from ERB.

The react_router_rails_spa gem does just this.

## Outline

The following is an outline of how the react_router_rails_spa gem works.

It is important to note that the gem does nothing more than a stock React Router installation with some custom configuration,
paired with a single Rails controller.

Since there is very little custom code, you can easily update your NPM packages independently of this gem.
Maintenance should be no harder than installing React Router by yourself.
The generated code is heavily commented to help you understand the internals for yourself.

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
The body of the response is the exact contents of the React Router-generated `index.html` file.
By passing it through the `ReactController`,
we can customize the headers and add session-specific information as cookies.

For example, `ReactController` includes  the `ReactRouterRailsSpa::CsrfCookieEnabled` module which sends the session-specific CSRF token via a cookie to integrate Rails' CSRF protection with React.

`ReactController` will also add session cookies so that you can take advantage of session information from the bootstrap HTML file onwards.

Finally, the `ReactController` allows you to set cache headers separately from assets served directly from the `assets` folder.

Rails uses the [ActionDispatch::Static middleware](https://api.rubyonrails.org/classes/ActionDispatch/Static.html)
to serve assets from the `public` folder,
and this sets the HTTP caching headers aggressively to allow extensive caching for long periods of time.
While this is great for JavaScript, CSS and image assets, this is usually undesirable for HTML files to which we cannot attach cache-busting digests.
Serving the bootstrap HTML template through `ReactController` allows us
to easily change the cache headers to values that are suitable for HTML responses.
The react_router_rails_spa gem uses the same cache headers as other ERB files,
but this can be customized in the controller. 

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
There are some minor configurations that we need for this.

We also need to add settings to compensate for the fact that the development server runs on port 5173 while the Rails application runs on port 3000.

Despite the above server settings,
the development server running on port 5173 is only suitable for testing the React application.
This means
that you cannot test interactions between the React pages and the ERB pages using the React Router development server.
In fact, the development server will not even send requests for the bootstrap HTML.
Instead,
you need to do a production build of the React application
which will host static files inside the Rails `public` folder just like in production.
This is similar to [what Vite does when previewing](https://vite.dev/guide/cli.html#vite-preview) with `vite preview`.

You can then test both your React and ERB views from port 3000.

The development server and its HMR capabilities are suitable for updating designs and small interactions.
If you encounter glitches when developing more complex features, try building and testing from port 3000.

## Demo and Source code

* I have a [demo application based on the current proposal running on Kamal on a VPS server](https://rrrails.castle104.com/react-router/). It has simple, session-based authentication and basic CRUD. Mutations are secured by integration with Rails CSRF protection.
* In the demo application, I have intentionally added a 2-second delay on all server requests. Even the most bloated and inefficient web technologies will look great on a high-performance device with a fast network. The only way to highlight technical issues is to run your site on a slow server and/or network.
* The source-code for this demo application is [available on GitHub](https://github.com/naofumi/react-router-vite-rails).

The source code is heavily commented. I recommend that you read through it to understand the setup in more detail.

## Steps to Intergrate React Router into your Rails Application

### Install Ruby on Rails

This gem works with a pre-existing installation of Rails. Create a new Rails application if you haven't already.

```shell
rails new [project name]
```

Note that this gem works even with a no-build Rails setup (which is the Rails default).

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

