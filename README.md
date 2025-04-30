# AWS-Terraform  - Next.JS - Portfolio Project
===============================================


This is a simple blog project built with Next.js. It uses the traditional pages directory for routing, making it suitable for small projects like blogs, portfolios, or landing pages.

* * * * *

Project Structure
-----------------


```
nextjs-blog-template/
│
├── .gitignore             # Files and directories to ignore in version control
├── .next/                 # Build output (auto-generated)
├── .nvmrc                 # Node.js version configuration
├── next.config.js         # Next.js configuration
├── package.json           # Project metadata and dependencies
├── pages/                 # Contains all page components (routes)
├── public/                # Static assets (accessible via URL)
├── README.md              # Project documentation
├── styles/                # CSS files for styling

```

### Key Files and Folders


-   `pages/` This folder defines routes using files. Each file corresponds to a route.

    -   Example: `pages/index.js` is the home route (`/`).
-   `public/` Contains static files like images, icons, and other assets. These files can be accessed directly via the browser, for example:

    ```
    /favicon.ico
    /vercel.svg

    ```

-   `styles/` Contains CSS files for styling the application.

    -   `global.css`: Global styles applied across the app.
    -   `Home.module.css`: Scoped styles specific to the home page.
-   `.gitignore` Lists files and folders to exclude from version control. This prevents unnecessary files like `node_modules` and `.next` from being committed to Git.

-   `next.config.js` Used to customize the default Next.js configuration.

-   `package.json` Includes project information, scripts, and dependencies.

* * * * *

How to Run the Project
----------------------



1.  Clone the repository:

    ```source-shell
    git clone <repository-url>
    cd nextjs-blog
    ```

2.  Install dependencies:

    ```source-shell
    npm install
    ```

3.  Run the development server:

    ```source-shell
    npm run dev
    ```

4.  Open your browser and go to:

    ```
    http://localhost:3000

    ```


Conclusion & next steps
-----------------------

This project follows the traditional pages directory routing approach in Next.js. It's a simple and effective setup for smaller applications like blogs or portfolios. The next step will be connecting a CI/CD pipeline to this project for DEVOPS.

Feel free to explore the code, customize the styles, and extend the functionality as needed.
