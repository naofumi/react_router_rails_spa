import logoDark from "./logo-dark.svg";
import logoLight from "./logo-light.svg";
import railsLogo from "./rails-logo.svg";

export function Welcome() {
  return (
    <main className="flex items-center justify-center pt-16 pb-4">
      <div className="flex-1 flex flex-col items-center gap-16 min-h-0">
        <header className="flex flex-row items-baseline gap-9 max-w-[100vw]">
          <div className="w-[300px]">
            <img
              src={logoLight}
              alt="React Router"
              className="block w-full dark:hidden"
            />
            <img
              src={logoDark}
              alt="React Router"
              className="hidden w-full dark:block"
            />
          </div>
          <div className="text-5xl text-gray-500 font-bold">on</div>
          <div className="text-red-500 w-[300px]">
            <img
              src={railsLogo}
              alt="Ruby on Rails"
              className="block w-full"
            />
          </div>
        </header>
        <div className="max-w-[300px] w-full space-y-6 px-4">
          <nav className="space-y-4">
            <p className="leading-6 text-gray-700 dark:text-gray-200 text-center">
              What&apos;s next?
            </p>
            <div className="text-center">
              {resources.map(({ href, text }) => (
                <a
                  key={href}
                  className="block mb-2 leading-normal text-blue-700 hover:underline dark:text-blue-500"
                  href={href}
                  target="_blank"
                  rel="noreferrer"
                >
                  {text}
                </a>
              ))}
            </div>
          </nav>
        </div>
      </div>
    </main>
  );
}

const resources = [
  {
    href: "https://reactrouter.com/docs",
    text: "React Router Docs",
  },
  {
    href: "https://rmx.as/discord",
    text: "Join Discord",
  },
];
