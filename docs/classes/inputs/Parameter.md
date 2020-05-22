A `Parameter` represents one or multiple deterministic values.

## Properties
The available properties that can be passed as name/value pairs to the constructor of `Parameter` are:

 - Description : `string`
 - Value : `numeric`

## Usage

To create a `Parameter` with a specific value and description:
``` matlab
p = opencossan.common.inputs.Parameter(...
    'Description', 'My Parameter', ...
    'value', 2);
```

A `Parameter` object returns the number of elements in `Value` as
``` matlab
n = p.Nelements;
```

