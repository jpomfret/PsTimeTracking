# Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Running the Tests

If want to know how to run this module's tests you can look at the [Testing Guidelines](https://dsccommunity.org/guidelines/testing-guidelines/#running-tests)

## Running things

Pull down the repo and then run the following to resolve dependencies and
download modules.

```PowerShell
./build.ps1 -ResolveDependency -Tasks noop
```

To build the thing

```Powershell
./build.ps1 -Tasks build
```
