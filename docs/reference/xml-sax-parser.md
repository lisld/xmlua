---
title: xmlua.XMLSAXParser
---

# `xmlua.XMLSAXParser` class

## Summary

It's a class for parsing a XML with SAX(Simple API for XML).

SAX is different from DOM, processing parse documents line by line.
DOM processing parse after read all documents into memory.
So, SAX can parse documents with much less memory and fast.

You can register your callback method which call when occured events below.

Call back event list:
  * StartDocument
  * ElementDeclaration
  * AttributeDeclaration
  * UnparsedEntityDeclaration
  * NotationDeclaration
  * EntityDeclaration
  * InternalSubset
  * ExternalSubset
  * CdataBlock
  * Comment
  * ProcessingInstruction
  * IgnorableWhitespace
  * Text
  * Reference
  * StartElement
  * EndElement
  * Warning
  * Error
  * EndDocument

## Class methods

### `xmlua.XMLSAXParser.new() -> XMLSAXParser` {#new}

It makes XMLSAXParser object.

You can make object of `xmllua.XMLSAXParser` class as below example.

Example:

```lua
local xmlua = require("xmlua")

local parser = xmlua.XMLSAXParser.new()
```

## Instance methods

### `parse(xml) -> boolean` {#parse}

`xml`: XML string to be parsed.

It parses the given XML.
If XML parsing is succeed, this method returns true. If XML parsing is failed, this method returns false.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [[
<?xml version="1.0" encoding="UTF-8" ?>
<root>Hello </root>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local xml = io.open("example.xml"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
local success = parser:parse(xml)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end
```

### `finish() -> boolean` {#finish}

It finishes parse XML with SAX.

If you started parse with `xmlua.XMLSAXParser.parse`, you should call this method.

If you don't call this method, `EndDocument` event isn't occure.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [[
<?xml version="1.0" encoding="UTF-8" ?>
<root>Hello </root>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local xml = io.open("example.xml"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
local success = parser:parse(xml)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

## Property

### `start_document`

It registers user call back function as below.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.start_document = function()
  -- You want to execute code
end
```

Registered function is called, when parse start document element.

Registered function is called, when parse `<root>` in below example.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [[
<xml>Hello</xml>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local xml = io.open("example.xml"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.start_document = function()
  print("Start document")
end
local success = parser:parse(xml)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
Start document
```

### `end_document`

It registers user call back function as below.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.end_document = function()
  -- You want to execute code
end
```

Registered function is called, when call `xmlua.XMLSAXParser.parser.finish`.

Registered function is called, when parse `parser:finish()` in below example.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [[
<xml>Hello</xml>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local html = io.open("example.html"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.end_document = function()
  print("End document")
end
local success = parser:parse(html)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
End document
```

### `processing_instruction`

It registers user call back function as below.

You can get attributes of processing instruction as argument of your call back. Attributes of processing instruction are `target` and `data_list` in below example.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.processing_instruction = function(target, data_list)
  -- You want to execute code
end
```

Registered function is called, when parse processing instruction element.

Registered function is called, when parse `<?target This is PI>` in below example.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [[
<?xml version="1.0" encoding="UTF-8" ?>
<?xml-stylesheet href="www.test.com/test-style.xsl" type="text/xsl" ?>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local html = io.open("example.html"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.processing_instruction = function(target, data_list)
  print("Processing instruction target: "..target)
  print("Processing instruction data: "..data_list)
end
local success = parser:parse(html)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
Processing instruction target: target
Processing instruction data: This is PI
```

### `cdata_block`

It registers user call back function as below.

You can get string in CDATA section as argument of your call back. String in CDATA section is `cdata_block`.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.cdata_block = function(cdata_block)
  -- You want to execute code
end
```

Registered function is called, when parse CDATA section.

Registered function is called, when parse `<![CDATA[<p>Hello world!</p>]]>` in below example.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [=[
<?xml version="1.0" encoding="UTF-8" ?>
<xml>
<![CDATA[<p>Hello world!</p>]]>
</xml>
]=]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local html = io.open("example.html"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.cdata_block = function(cdata_block)
  print("CDATA block: "..cdata_block)
end
local success = parser:parse(html)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
CDATA block: <p>Hello world!</p>
```

### `ignorable_whitespace`

It registers user call back function as below.

You can get ignorable whitespace in XML as argument of your call back. ignorable whitespace in XML is `ignorable_whitespace` in below example.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.ignorable_whitespace = function(ignorable_whitespace)
  -- You want to execute code
end
```

Registered function is called, when parse ignorable whitespace

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [[
<?xml version="1.0" encoding="UTF-8" ?>
<xml>
  <test></test>
</xml>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local html = io.open("example.html"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.ignorable_whitespace = function(ignorable_whitespace)
  print("Ignorable whitespace: ".."\""..ignorable_whitespace.."\"")
end
local success = parser:parse(html)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
Ignorable whitespace: "
  "
Ignorable whitespace: "
"
```

### `comment`

It registers user call back function as below.

You can get comment of XML as argument of your call back. comment in XML is `comment` in below example.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.comment = function(comment)
  -- You want to execute code
end
```

Registered function is called, when parse XML's comment.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [[
<?xml version="1.0" encoding="UTF-8" ?>
<xml><!--This is comment--></xml>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local html = io.open("example.html"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.comment = function(comment)
  print("Comment: "..comment)
end
local success = parser:parse(html)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
Comment:  This is comment.
```

### `start_element`

It registers user call back function as below.

You can get name and attributes of elements as argument of your call back.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.start_element = function(local_name,
                                prefix,
                                uri,
                                namespaces,
                                attributes)
  -- You want to execute code
end
```

Registered function is called, when parse element.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [[
<?xml version="1.0" encoding="UTF-8" ?>
<xhtml:html xmlns:xhtml="http://www.w3.org/1999/xhtml"
  id="top"
  xhtml:class="top-level">
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local html = io.open("example.html"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.start_element = function(local_name,
                                prefix,
                                uri,
                                namespaces,
                                attributes)
  print("Start element: " .. local_name)
  if prefix then
    print("  prefix: " .. prefix)
  end
  if uri then
    print("  URI: " .. uri)
  end
  for namespace_prefix, namespace_uri in pairs(namespaces) do
    if namespace_prefix  == "" then
      print("  Default namespace: " .. namespace_uri)
    else
      print("  Namespace: " .. namespace_prefix .. ": " .. namespace_uri)
    end
  end
  if attributes then
    if #attributes > 0 then
      print("  Attributes:")
      for i, attribute in pairs(attributes) do
        local name
        if attribute.prefix then
          name = attribute.prefix .. ":" .. attribute.local_name
        else
          name = attribute.local_name
        end
        if attribute.uri then
          name = name .. "{" .. attribute.uri .. "}"
        end
        print("    " .. name .. ": " .. attribute.value)
      end
    end
  end
end

local success = parser:parse(html)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
Start element: html
  prefix: xhtml
  URI: http://www.w3.org/1999/xhtml
  Namespace: xhtml: http://www.w3.org/1999/xhtml
  Attributes:
    id: top
    xhtml:class{http://www.w3.org/1999/xhtml}: top-level
```

### `end_element`

It registers user call back function as below.

You can get name of elements as argument of your call back.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.end_element = function(local_name,
                              prefix,
                              uri)
  -- You want to execute code
end
```

Registered function is called, when parse end element.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local xml = [[
<?xml version="1.0" encoding="UTF-8" ?>
<xhtml:html xmlns:xhtml="http://www.w3.org/1999/xhtml">
</xhtml:html>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local xml = io.open("example.xml"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.end_element = function(name)
  print("End element: " .. local_name)
  if prefix then
    print("  prefix: " .. prefix)
  end
  if uri then
    print("  URI: " .. uri)
  end
end

local success = parser:parse(xml)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
End element: html
  prefix: xhtml
  URI: http://www.w3.org/1999/xhtml
```

### `text`

It registers user call back function as below.

You can get text of text element as argument of your call back.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.text = function(text)
  -- You want to execute code
end
```

Registered function is called, when parse text element.

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local html = [[
<?xml version="1.0" encoding="UTF-8"?>
<book>
  <title>Hello World</title>
</book>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local html = io.open("example.html"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.text = function(text)
  print("Text: " .. text)
end

local success = parser:parse(html)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
Text:   
Text: Hello World
```

### `error`

It registers user call back function as below.

You can get error information of parse XML with SAX as argument of your call back.

```lua
local parser = xmlua.XMLSAXParser.new()
parser.error = function(error)
  -- You want to execute code
end
```

Registered function is called, when parse failed.
Error information structure as below.

```
{
  domain
  code
  message
  level
  line
}
```

`domain` has values as specific as below.
[`Error domain list`][error-domain-list]

`code` has values as specific as below.
[`Error code list`][error-code-list]

`level` has values as specific as below.
[`Error level list`][error-level-list]

Example:

```lua
local xmlua = require("xmlua")

-- XML to be parsed
local html = [[
<>
]]

-- If you want to parse text in a file,
-- you need to read file content by yourself.

-- local html = io.open("example.html"):read("*all")

-- Parses XML with SAX
local parser = xmlua.XMLSAXParser.new()
parser.error = function(error)
  print("Error domain : " .. error.domain)
  print("Error code   : " .. error.code)
  print("Error message: " .. error.message)
  print("Error level  : " .. error.level)
  print("Error line   : " .. error.line)
end

local success = parser:parse(html)
if not success then
  print("Failed to parse XML with SAX")
  os.exit(1)
end

parser:finish()
```

Result of avobe example as blow.

```
Error domain :	1
Error code :	5
Error message :Extra content at the end of the document

Error level :	3
Error line :	1
Failed to parse XML with SAX
```

[error-domain-list]:error-domain-list.html
[error-code-list]:error-code-list.html
[error-level-list]:error-level-list.html