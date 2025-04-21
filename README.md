## React Router SPA Framework mode integration for Ruby on Rails

The react_router_rails_spa gem integrates [React Router in SPA Framework mode](https://reactrouter.com/how-to/spa) with your Ruby on Rails application.

The React app is built as a static SPA.
Static assets will be built in your Rails `public` folder,
and will be deployed on your current production server with minimal, if any, configuration changes.

With a single gem and a single command,
this gem sets up all that you need in  ["Omakase"](https://dhh.dk/2012/rails-is-omakase.html)-style – An integrated client-side router,
per-route code-splitting, the loader data-fetch pattern, Rails controllers and routes –
All of this will be automatically set up for you.  

[Read the introduction](https://github.com/naofumi/react_router_rails_spa/blob/main/documents/introduction.md) for more background: 

## Who is it for?

Consider trying out this gem if any of the below apply to you.

- You want an out-of-the-box solution. 
  - You do not enjoy installing React, React Router, Tailwind, configuring code-splitting, and deciding the data-loading scheme that you will use throughout your application. You want ["Omakase"](https://dhh.dk/2012/rails-is-omakase.html) on the front-end as well as your Rails back-end. 
- You do not need SEO, at least not for the React pages.
  - You can always use ERB views for the pages that need SEO.
- You are tired of managing multiple servers for your frontend and your backend.
  - You do not want to incur the additional costs, complexity, and authentication concerns that are inherent when dealing with multiple servers, for no concrete benefit.
  - You want to simply deploy your React frontend as static assets on a single server, inside your Ruby on Rails `public` folder.
- You have many pages, and you want to reduce the initial JavaScript payload size by using automatic code-splitting and lazy-loading, but without sacrificing performance due to request waterfalls.

## Installation

We assume that you already have an existing Ruby on Rails application.

Add this line to your application's Gemfile:

```ruby
gem 'react_router_rails_spa'
```

Then, run:

```shell
bundle install
```

followed by:

```shell
bin/rails generate react_router_rails_spa:install
```

This will create a new directory called `frontend` inside the project root.
This is where your React application is.

It will also create a React bootstrap endpoint in your Rails routes for all paths starting with `/react`.
The endpoint will be handled by `ReactController#show`.

## Running the React Router development server

React Router is built with Vite and uses the Vite development server to provide a Hot Module Replacement (HMR) capability.

Start the Vite development server with the following command
(we assume that the Ruby on Rails server is already running (with either the `bin/rails s` or the `bin/dev` command).

```shell
bin/rails react_router:dev
```

Note that the development server will not fully represent the application's behavior in production.
In particular, the development server is only partially integrated with Rails.
We therefore strongly recommend that you build the React Router assets into the `public` folder and preview it before deploying into production.

To preview the production build, run the following command.
```shell
bin/rails react_router:preview
```

This will build the React Router application into the Rails `public` folder.
The React Router application will be available from the Rails development server
(puma) at `http://localhost:3000/react`.
This preview will be representative of the production app's behavior with Rails integration.

## Deployment

This gem integrates with the Ruby on Rails Asset pipeline, and the React application is automatically built whenever `bin/rails assets:precompile` is run.
No changes are required on your deployment script, since your Ruby on Rails application should run this command.

If your deployment pipeline does not already install Node (for example, you have a "no-build" deployment for Rails),
then install it in your CI/CD environment since building the React Router application will require it. 

## Background

Ruby on Rails has officially supported bundling of complex JavaScript frontend libraries,
first with [Webpacker](https://github.com/rails/webpacker),
and currently with [jsbundling-rails](https://github.com/rails/jsbundling-rails).
We also have [Vite Ruby](https://github.com/ElMassimo/vite_ruby) with an integrated dev server, HMR and other goodies.

However, on February 14th, 2025,
the React team announced the [official deprecation of Create React App (CRA)](https://react.dev/blog/2025/02/14/sunsetting-create-react-app).
Instead, they suggested developers should use a framework that builds single-page apps
(SPA) deployable to a CDN or a static hosting service –
In other words, SPA frameworks such as Next.js or React Router.
Importantly,
they advised
against [building a React app from scratch](https://react.dev/learn/build-a-react-app-from-scratch)
unless your app has constraints not well-served by existing SPA frameworks.

This approach poses challenges to the traditional Rails integration solutions.
They all compile the React applications to a single JavaScript file
that is then loaded from an ERB file (the React bootstrap HTML) containing helper functions such as
`javascript_include_tag` (jsbundling-rails), `javascript_pack_tag` (webpacker), or `vite_javascript_tag` (vite-rails).
However, SPA frameworks do not just compile to a single JavaScript file.
Instead,
they additionally generate their own React bootstrap HTML file which includes many framework-specific optimizations
(React Router v7 generates this using SSG from `app/root.tsx`).

This gem uses the bootstrap HTML file
generated by the SPA framework instead of an ERB file.
This is served through an ActionController endpoint,
enabling you to use cookies to send session-specific information on the first HTML load
and is used in this gem to send CSRF tokens.

## Notes when using Rails in API mode

Ruby on Rails provides an API mode that removes many frontend features.
Importantly, API mode implies a stateless API server that does not support cookies.
It removes the middleware for cookie handling and also for CSRF protection.

To fully benefit from hosting your React app inside Rails' `public` folder, we recommend that you avoid API-mode and instead use cookies for authentication.

If you want to convert your API-mode application to use cookies, make sure to also restore CSRF features.
Otherwise, your app will be vulnerable to CSRF attacks.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/naofumi/react_router_rails_spa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/naofumi/react_router_rails_spa/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ReactRouterRailSpa project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/naofumi/react_router_rails_spa/blob/main/CODE_OF_CONDUCT.md).
