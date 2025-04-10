## React Router SPA Framework mode integration for Ruby on Rails

Integrate [React Router in SPA Framework mode](https://reactrouter.com/how-to/spa) into your Ruby on Rails application
and deploy as static assets from your Rails `public` folder.
Benefit from the integrated client-side router, loader data-fetching pattern,
automatic code-splitting, and development server with HMR,
without the costs and complexities of running a separate front-end server.

If you are using Next.js, not because you need to prioritize SEO,
but mainly for convenience,
if you are not using SSR but predominantly fetching data on the client-side,
then this gem may provide you with a simpler, cheaper and more performant solution.

You may be considering the traditional approaches to React and Rails integration such as [Webpacker](https://github.com/rails/webpacker),
[jsbundling-rails](https://github.com/rails/jsbundling-rails), [Vite Ruby](https://github.com/ElMassimo/vite_ruby)
but concerned about installing and configuring additional packages, and avoiding common SPA pitfalls.
The React Router SPA framework mode in this gem includes the router, reduces your bundle size through automatic per-route code-splitting,
and eliminates data-fetch waterfalls through the loader data-fetch pattern.

The generator in this gem will install React Router and [configure it for an SPA as a framework](https://reactrouter.com/how-to/spa).

## Who is it for?

- You want to use integrate React into a Ruby on Rails application.
  - The Ruby on Rails application may already have ERB (Hotwire) pages.
- You do not need SEO for the React generated pages (you don't need SSR/SSG).
  - You can always use ERB views when SEO is a priority.
- You do not want to host your frontend on a separate server due to costs, complexity, and authentication concerns.
  - You want to simply deploy your React frontend as static assets inside your Ruby on Rails `public` folder.
- You have many pages, and you want to reduce the initial JavaScript payload size by using automatic code-splitting and lazy-loading, but without sacrificing performance due to request waterfalls.

## Installation

We assume that you have an existing Ruby on Rails application,
and you will to create a new React Router frontend inside the `frontend` directory.

Add this line to your application's Gemfile:

```ruby
gem 'react_router_rails_spa'
```

Then, run:

```shell
bundle install
bin/rails generate react_router_rails_spa:install
```

This will create a new directory called `frontend` inside the project root.
It will also create a React bootstrap endpoint `/react` handled by `ReactController#show`,
rake tasks for starting the dev server and building the React app.
It also adds `include ReactRouterRailsSpa::CsrfCookieEnabled` to your `ApplicationController` to allow you to use the robust CSRF protection built into Ruby on Rails from your React application.

## Running in Development

Start the Ruby on Rails server (either `bin/rails s` or `bin/dev`) and then run the following command to start the React Router development server.

```shell
bin/rails react_router:dev
```

Access the development server from the URL outputted from this command (Typically `http://localhost:5173/react`)

The development server gives you HMR and is helpful when editing pages generated by the React app. However,
there are significant differences compared to the production environment,
especially with regard to how the React pages interact with Ruby on Rails.

You should always assume that the development server is only an approximation.
You are advised to build the React app and access it from the Ruby on Rails server to ensure that it works as intended. 

Run the following command to build the React app. The React page will be available from the Ruby on Rails server
and will represent what you will see in production.
(`http://localhost:3000/react`)

```shell
bin/rails react_router:build
```

## Deployment

This gem integrates with the Ruby on Rails Asset pipeline.
The React Router application is automatically built whenever `bin/rails assets:precompile` is run
and no changes should be required if your Ruby on Rails application already does this.

If your deployment pipeline does not already install Node (for example, you have a "no-build" deployment for Rails),
then install it in your build environment since building the React Router application will require it.

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

## 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/naofumi/react_router_rails_spa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/naofumi/react_router_rails_spa/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ReactRouterRailSpa project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/naofumi/react_router_rails_spa/blob/main/CODE_OF_CONDUCT.md).
