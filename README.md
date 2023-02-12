# myhelm_custom


helm function required for us future use how to define in _helpers.tpl file and call those values in all files in template folder

# For data structures that have both a key and a value, we can use range to get both. For example, we can loop through .Values.favorite like this:**

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  {{- range $key, $val := .Values.favorite }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
  
#  equal and not equal**
  eq
Returns the boolean equality of the arguments (e.g., Arg1 == Arg2).

eq .Arg1 .Arg2
ne
Returns the boolean inequality of the arguments (e.g., Arg1 != Arg2)

ne .Arg1 .Arg2




# trimPrefix**
Trim just the prefix from a string:

trimPrefix "-" "-hello"
The above returns hello

# trimSuffix**
Trim just the suffix from a string:

trimSuffix "-" "hello-"
The above returns hello



# trunc**
Truncate a string

trunc 5 "hello world"
The above produces hello.

trunc -5 "hello world"
The above produces world.

# contains
Test to see if one string is contained inside of another:**

contains "cat" "catch"
The above returns true because catch contains cat.

hasPrefix and hasSuffix
The hasPrefix and hasSuffix functions test whether a string has a given prefix or suffix:

hasPrefix "cat" "catch"
The above returns true because catch has the prefix cat.

# quote and squote**
These functions wrap a string in double quotes (quote) or single quotes (squote).

cat
The cat function concatenates multiple strings together into one, separating them with spaces:

cat "hello" "beautiful" "world"
The above produces hello beautiful world

# indent**
The indent function indents every line in a given string to the specified indent width. This is useful when aligning multi-line strings:

indent 4 $lots_of_text
The above will indent every line of text by 4 space characters.

# nindent**
The nindent function is the same as the indent function, but prepends a new line to the beginning of the string.

nindent 4 $lots_of_text
The above will indent every line of text by 4 space characters and add a new line to the beginning.







# fromYaml
The fromYaml function takes a YAML string and returns an object that can be used in templates.**

File at: yamls/person.yaml

name: Bob
age: 25
hobbies:
  - hiking
  - fishing
  - cooking
{{- $person := .Files.Get "yamls/person.yaml" | fromYaml }}
greeting: |
  Hi, my name is {{ $person.name }} and I am {{ $person.age }} years old.
  My hobbies are {{ range $person.hobbies }}{{ . }} {{ end }}.  
  
  
# fromJson
The fromJson function takes a YAML string and returns an object that can be used in templates.**

File at: jsons/person.json

{
  "name": "Bob",
  "age": 25,
  "hobbies": [
    "hiking",
    "fishing",
    "cooking"
  ]
}
{{- $person := .Files.Get "jsons/person.json" | fromJson }}
greeting: |
  Hi, my name is {{ $person.name }} and I am {{ $person.age }} years old.
  My hobbies are {{ range $person.hobbies }}{{ . }} {{ end }}.  
  
  
  


# with function**
**Modifying scope using with
The next control structure to look at is the with action. This controls variable scoping. Recall that . is a reference to the current scope. So .Values tells the template to find the Values object in the current scope.

The syntax for with is similar to a simple if statement:**

{{ with PIPELINE }}
  # restricted scope
{{ end }}
Scopes can be changed. with can allow you to set the current scope (.) to a particular object. For example, we've been working with .Values.favorite. Let's rewrite our ConfigMap to alter the . scope to point to .Values.favorite:

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  {{- with .Values.favorite }}
  drink: {{ .drink | default "tea" | quote }}
  food: {{ .food | upper | quote }}
  {{- end }}
Note that we removed the if conditional from the previous exercise because it is now unnecessary - the block after with only executes if the value of PIPELINE is not empty.

Notice that now we can reference .drink and .food without qualifying them. That is because the with statement sets . to point to .Values.favorite. The . is reset to its previous scope after {{ end }}.

But here's a note of caution! Inside of the restricted scope, you will not be able to access the other objects from the parent scope using .. This, for example, will fail:

  {{- with .Values.favorite }}
  drink: {{ .drink | default "tea" | quote }}
  food: {{ .food | upper | quote }}
  release: {{ .Release.Name }}
  {{- end }}
It will produce an error because Release.Name is not inside of the restricted scope for .. However, if we swap the last two lines, all will work as expected because the scope is reset after {{ end }}.

  {{- with .Values.favorite }}
  drink: {{ .drink | default "tea" | quote }}
  food: {{ .food | upper | quote }}
  {{- end }}
  release: {{ .Release.Name }}
Or, we can use $ for accessing the object Release.Name from the parent scope. $ is mapped to the root scope when template execution begins and it does not change during template execution. The following would work as well:

  {{- with .Values.favorite }}
  drink: {{ .drink | default "tea" | quote }}
  food: {{ .food | upper | quote }}
  release: {{ $.Release.Name }}
  {{- end }}
After looking at range, we will take a look at template variables, which offer one solution to the scoping issue above.

# Looping with the range action
Many programming languages have support for looping using for loops, foreach loops, or similar functional mechanisms. In Helm's template language, the way to iterate through a collection is to use the range operator.**

To start, let's add a list of pizza toppings to our values.yaml file:

favorite:
  drink: coffee
  food: pizza
pizzaToppings:
  - mushrooms
  - cheese
  - peppers
  - onions
Now we have a list (called a slice in templates) of pizzaToppings. We can modify our template to print this list into our ConfigMap:

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  {{- with .Values.favorite }}
  drink: {{ .drink | default "tea" | quote }}
  food: {{ .food | upper | quote }}
  {{- end }}
  toppings: |-
    {{- range .Values.pizzaToppings }}
    - {{ . | title | quote }}
    {{- end }}    
We can use $ for accessing the list Values.pizzaToppings from the parent scope. $ is mapped to the root scope when template execution begins and it does not change during template execution. The following would work as well:

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  {{- with .Values.favorite }}
  drink: {{ .drink | default "tea" | quote }}
  food: {{ .food | upper | quote }}
  toppings: |-
    {{- range $.Values.pizzaToppings }}
    - {{ . | title | quote }}
    {{- end }}    
  {{- end }}
Let's take a closer look at the toppings: list. The range function will "range over" (iterate through) the pizzaToppings list. But now something interesting happens. Just like with sets the scope of ., so does a range operator. Each time through the loop, . is set to the current pizza topping. That is, the first time, . is set to mushrooms. The second iteration it is set to cheese, and so on.

We can send the value of . directly down a pipeline, so when we do {{ . | title | quote }}, it sends . to title (title case function) and then to quote. If we run this template, the output will be:

# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: edgy-dragonfly-configmap
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "PIZZA"
  toppings: |-
    - "Mushrooms"
    - "Cheese"
    - "Peppers"
    - "Onions"    
Now, in this example we've done something tricky. The toppings: |- line is declaring a multi-line string. So our list of toppings is actually not a YAML list. It's a big string. Why would we do this? Because the data in ConfigMaps data is composed of key/value pairs, where both the key and the value are simple strings. To understand why this is the case, take a look at the Kubernetes ConfigMap docs. For us, though, this detail doesn't matter much.

The |- marker in YAML takes a multi-line string. This can be a useful technique for embedding big blocks of data inside of your manifests, as exemplified here.
Sometimes it's useful to be able to quickly make a list inside of your template, and then iterate over that list. Helm templates have a function to make this easy: tuple. In computer science, a tuple is a list-like collection of fixed size, but with arbitrary data types. This roughly conveys the way a tuple is used.

  sizes: |-
    {{- range tuple "small" "medium" "large" }}
    - {{ . }}
    {{- end }}    
The above will produce this:

  sizes: |-
    - small
    - medium
    - large    
In addition to lists and tuples, range can be used to iterate over collections that have a key and a value (like a map or dict). We'll see how to do that in the next section when we introduce template variables.








# Setting the scope of a template**
In the template we defined above, we did not use any objects. We just used functions. Let's modify our defined template to include the chart name and chart version:

{{/* Generate basic labels */}}
{{- define "mychart.labels" }}
  labels:
    generator: helm
    date: {{ now | htmlDate }}
    chart: {{ .Chart.Name }}
    version: {{ .Chart.Version }}
{{- end }}
If we render this, we will get an error like this:

$ helm install --dry-run moldy-jaguar ./mychart
Error: unable to build kubernetes objects from release manifest: error validating "": error validating data: [unknown object type "nil" in ConfigMap.metadata.labels.chart, unknown object type "nil" in ConfigMap.metadata.labels.version]
To see what rendered, re-run with --disable-openapi-validation: helm install --dry-run --disable-openapi-validation moldy-jaguar ./mychart. The result will not be what we expect:

# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: moldy-jaguar-configmap
  labels:
    generator: helm
    date: 2021-03-06
    chart:
    version:
What happened to the name and version? They weren't in the scope for our defined template. When a named template (created with define) is rendered, it will receive the scope passed in by the template call. In our example, we included the template like this:

{{- template "mychart.labels" }}
No scope was passed in, so within the template we cannot access anything in .. This is easy enough to fix, though. We simply pass a scope to the template:

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  {{- template "mychart.labels" . }}
Note that we pass . at the end of the template call. We could just as easily pass .Values or .Values.favorite or whatever scope we want. But what we want is the top-level scope.

Now when we execute this template with helm install --dry-run --debug plinking-anaco ./mychart, we get this:

# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: plinking-anaco-configmap
  labels:
    generator: helm
    date: 2021-03-06
    chart: mychart
    version: 0.1.0
Now {{ .Chart.Name }} resolves to mychart, and {{ .Chart.Version }} resolves to 0.1.0.

# The include function
Say we've defined a simple template that looks like this:**

{{- define "mychart.app" -}}
app_name: {{ .Chart.Name }}
app_version: "{{ .Chart.Version }}"
{{- end -}}
Now say I want to insert this both into the labels: section of my template, and also the data: section:

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  labels:
    {{ template "mychart.app" . }}
data:
  myvalue: "Hello World"
  {{- range $key, $val := .Values.favorite }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
{{ template "mychart.app" . }}
If we render this, we will get an error like this:

$ helm install --dry-run measly-whippet ./mychart
Error: unable to build kubernetes objects from release manifest: error validating "": error validating data: [ValidationError(ConfigMap): unknown field "app_name" in io.k8s.api.core.v1.ConfigMap, ValidationError(ConfigMap): unknown field "app_version" in io.k8s.api.core.v1.ConfigMap]
To see what rendered, re-run with --disable-openapi-validation: helm install --dry-run --disable-openapi-validation measly-whippet ./mychart. The output will not be what we expect:

# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: measly-whippet-configmap
  labels:
    app_name: mychart
app_version: "0.1.0"
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "pizza"
app_name: mychart
app_version: "0.1.0"
Note that the indentation on app_version is wrong in both places. Why? Because the template that is substituted in has the text aligned to the left. Because template is an action, and not a function, there is no way to pass the output of a template call to other functions; the data is simply inserted inline.

To work around this case, Helm provides an alternative to template that will import the contents of a template into the present pipeline where it can be passed along to other functions in the pipeline.

Here's the example above, corrected to use indent to indent the mychart.app template correctly:

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  labels:
{{ include "mychart.app" . | indent 4 }}
data:
  myvalue: "Hello World"
  {{- range $key, $val := .Values.favorite }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
{{ include "mychart.app" . | indent 2 }}
Now the produced YAML is correctly indented for each section:

# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: edgy-mole-configmap
  labels:
    app_name: mychart
    app_version: "0.1.0"
data:
  myvalue: "Hello World"
  drink: "coffee"
  food: "pizza"
  app_name: mychart
  app_version: "0.1.0"
It is considered preferable to use include over template in Helm templates simply so that the output formatting can be handled better for YAML documents.
Sometimes we want to import content, but not as templates. That is, we want to import files verbatim. We can achieve this by accessing files through the .Files object described in the next section.  



# multiple config file accessing
Basic example
With those caveats behind, let's write a template that reads three files into our ConfigMap. To get started, we will add three files to the chart, putting all three directly inside of the mychart/ directory.

config1.toml:

message = Hello from config 1
config2.toml:

message = This is config 2
config3.toml:

message = Goodbye from config 3
Each of these is a simple TOML file (think old-school Windows INI files). We know the names of these files, so we can use a range function to loop through them and inject their contents into our ConfigMap.

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  {{- $files := .Files }}
  {{- range tuple "config1.toml" "config2.toml" "config3.toml" }}
  {{ . }}: |-
        {{ $files.Get . }}
  {{- end }}
This config map uses several of the techniques discussed in previous sections. For example, we create a $files variable to hold a reference to the .Files object. We also use the tuple function to create a list of files that we loop through. Then we print each file name ({{ . }}: |-) followed by the contents of the file {{ $files.Get . }}.

Running this template will produce a single ConfigMap with the contents of all three files:

# Source: mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: quieting-giraf-configmap
data:
  config1.toml: |-
        message = Hello from config 1

  config2.toml: |-
        message = This is config 2

  config3.toml: |-
        message = Goodbye from config 3















