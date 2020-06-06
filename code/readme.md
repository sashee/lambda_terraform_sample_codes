## How to use

* ```terraform init```
* ```terraform apply```
* go to the resulting URL
* cleanup: ```terraform destroy```

## Examples

There are 3 examples in the code, and you need to uncomment the one you'd like to inspect.

### Inline code

This is the [default](code/main.tf#L49), it uses the HEREDOC syntax to define the Lambda code.

### File interpolation

Comment out the default example and uncomment the [second example](code/main.tf#L53) codes. This loads the main.js and the index.html files.

### Directory

Comment out the default, run ```npm ci``` in the ```src``` directory, then uncomment the [third example](code/main.tf#L57). This zips the whole ```src``` directory and the ```node_modules``` with it, allowing the use of arbitrary npm dependencies.

In this case, it's using Mustache to render the HTML.
