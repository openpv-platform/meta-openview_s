# Dev environment
We have a few tools that all developers will probably want to make contributing to the rcd project easier.

# Electron App Development
If you're developing electron apps, you will want to set up the following in your environment.

NOTE: This is assuming you are running on a linux build or linux VM

Please install the following:
+ Node.js (I have version 16)
+ Npm (I have version 8)

Electron apps can interface with the RCD board via a custom-made node extension that wraps low-level code in a nice, user-friendly Node api. This module is distributed via npm from a private helios-owned NPM registry.

### To connect to our NPM registry, you will need to add it to your npm config. The steps are below:
1. Sign into DevOps, click on your user settings => "Personal Access Tokens"
2. Make a new Personal Access Token called "NPM Access". I typically make mine have a very long expiration (like 2024). The only permissions you will need are "Read" permissions to the "Release" section. If you are developing the sdk, you will want all the permissions in the "Release" section (read, write, execute, manage).
3. Once the token is made, it will give you a random string that you need to copy to your clipboard.
4. Run the following command, using the token, and copy the output to your clipboard. This output is your `b64Token`:
   ```
   echo -n "<YOUR_TOKEN>" | base64
   ```
5. Make a new user `~/.npmrc` file and paste the following template into it. Make sure to substitute in your `b64Token` to <B64_TOKEN> in the template:
```
; begin auth token
//pkgs.dev.azure.com/HeliosEngineering/_packaging/node-registry/npm/registry/:username=HeliosEngineering
//pkgs.dev.azure.com/HeliosEngineering/_packaging/node-registry/npm/registry/:_password=<B64_TOKEN>
//pkgs.dev.azure.com/HeliosEngineering/_packaging/node-registry/npm/registry/:email=npm requires email to be set but doesn't use the value
//pkgs.dev.azure.com/HeliosEngineering/_packaging/node-registry/npm/:username=HeliosEngineering
//pkgs.dev.azure.com/HeliosEngineering/_packaging/node-registry/npm/:_password=<B64_TOKEN>
//pkgs.dev.azure.com/HeliosEngineering/_packaging/node-registry/npm/:email=npm requires email to be set but doesn't use the value
; end auth token
```

Once you've done this, your computer can now pull npm packages from our private npm repository. You should now be able to `npm install` the hlio-rcd-applications and npm will pull down the appropriate Node extensions and C libraries to run on the rcd board.
