local XMLSAXParser = {}

local libxml2 = require("xmlua.libxml2")
local ffi = require("ffi")
local converter = require("xmlua.converter")
local to_string = converter.to_string

local methods = {}

local metatable = {}
function metatable.__index(parser, key)
  return methods[key]
end

local function create_start_document_callback(user_callback)
  local callback = function(user_data)
    user_callback()
  end
  local c_callback = ffi.cast("startDocumentSAXFunc", callback)
  ffi.gc(c_callback, function() c_callback:free() end)
  return c_callback
end

local function create_processing_instruction_callback(user_callback)
  local callback = function(user_data, raw_target, raw_data)
    print("in callback")
    local target = to_string(raw_target)
    local data = to_string(raw_data)
    user_callback(target, data)
  end
  local c_callback = ffi.cast("processingInstructionSAXFunc", callback)
  ffi.gc(c_callback, function() c_callback:free() end)
  return c_callback
end

local function create_ignorable_whitespace_callback(user_callback)
  local callback = function(user_data,
                            raw_ignorable_whitespaces,
                            raw_length)
    local ignorable_whitespaces = to_string(raw_ignorable_whitespaces,
                                            raw_length)
    user_callback(ignorable_whitespaces)
  end
  local c_callback = ffi.cast("ignorableWhitespaceSAXFunc", callback)
  ffi.gc(c_callback, function() c_callback:free() end)
  return c_callback
end

local function create_text_callback(user_callback)
  local callback = function(user_data, raw_text, raw_length)
    user_callback(to_string(raw_text, raw_length))
  end
  local c_callback = ffi.cast("charactersSAXFunc", callback)
  ffi.gc(c_callback, function() c_callback:free() end)
  return c_callback
end

local function create_reference_callback(user_callback)
  local callback = function(user_data, raw_entity_name)
    user_callback(to_string(raw_entity_name))
  end
  local c_callback = ffi.cast("referenceSAXFunc", callback)
  ffi.gc(c_callback, function() c_callback:free() end)
  return c_callback
end

local function create_start_element_callback(user_callback)
  local callback = function(user_data,
                            raw_local_name,
                            raw_prefix,
                            raw_uri,
                            n_namespaces,
                            raw_namespaces,
                            n_attributes,
                            n_defaulted,
                            raw_attributes)
    local namespaces = {}
    for i = 1, n_namespaces do
      local base_index = (2 * (i - 1))
      local prefix = to_string(raw_namespaces[base_index + 0])
      local uri = to_string(raw_namespaces[base_index + 1])
      if prefix then
        namespaces[prefix] = uri
      else
        namespaces[""] = uri
      end
    end
    local attributes = {}
    for i = 1, n_attributes + n_defaulted do
      local base_index = (5 * (i - 1))
      local raw_attribute_local_name = raw_attributes[base_index + 0]
      local raw_attribute_prefix = raw_attributes[base_index + 1]
      local raw_attribute_uri = raw_attributes[base_index + 2]
      local raw_attribute_value = raw_attributes[base_index + 3]
      local raw_attribute_end = raw_attributes[base_index + 4]
      local attribute = {
        local_name = to_string(raw_attribute_local_name),
        prefix = to_string(raw_attribute_prefix),
        uri = to_string(raw_attribute_uri),
        value = to_string(raw_attribute_value,
                          raw_attribute_end - raw_attribute_value),
        is_default = i > n_attributes,
      }
      table.insert(attributes, attribute)
    end
    user_callback(to_string(raw_local_name),
                  to_string(raw_prefix),
                  to_string(raw_uri),
                  namespaces,
                  attributes)
  end
  local c_callback = ffi.cast("startElementNsSAX2Func", callback)
  ffi.gc(c_callback, function() c_callback:free() end)
  return c_callback
end

local function create_end_element_callback(user_callback)
  local callback = function(user_data,
                            raw_local_name,
                            raw_prefix,
                            raw_uri)
    user_callback(to_string(raw_local_name),
                  to_string(raw_prefix),
                  to_string(raw_uri))
  end
  local c_callback = ffi.cast("endElementNsSAX2Func", callback)
  ffi.gc(c_callback, function() c_callback:free() end)
  return c_callback
end

local function create_end_document_callback(user_callback)
  local callback = function(user_data)
    user_callback()
  end
  local c_callback = ffi.cast("endDocumentSAXFunc", callback)
  ffi.gc(c_callback, function() c_callback:free() end)
  return c_callback
end

function metatable.__newindex(parser, key, value)
  if key == "start_document" then
    value = create_start_document_callback(value)
    parser.context.sax.startDocument = value
  elseif key == "processing_instruction" then
    value = create_processing_instruction_callback(value)
    parser.context.sax.processingInstruction = value
  elseif key == "ignorable_whitespace" then
    value = create_ignorable_whitespace_callback(value)
    parser.context.sax.ignorableWhitespace = value
 elseif key == "text" then
    value = create_text_callback(value)
    parser.context.sax.characters = value
  elseif key == "reference" then
    value = create_reference_callback(value)
    parser.context.sax.reference = value
  elseif key == "start_element" then
    value = create_start_element_callback(value)
    parser.context.sax.startElementNs = value
  elseif key == "end_element" then
    value = create_end_element_callback(value)
    parser.context.sax.endElementNs = value
  elseif key == "end_document" then
    value = create_end_document_callback(value)
    parser.context.sax.endDocument = value
  end
  rawset(parser, key, value)
end

function methods.parse(self, chunk)
  local parser_error = libxml2.xmlParseChunk(self.context, chunk, false)
  return parser_error == ffi.C.XML_ERR_OK
end

function methods.finish(self)
  local parser_error = libxml2.xmlParseChunk(self.context, nil, true)
  return parser_error == ffi.C.XML_ERR_OK
end

function XMLSAXParser.new()
  local parser = {}

  local filename = nil
  parser.context = libxml2.xmlCreatePushParserCtxt(filename)
  if not parser.context then
    error("Failed to create context to parse XML")
  end
  parser.context.sax.initialized = libxml2.XML_SAX2_MAGIC

  setmetatable(parser, metatable)

  return parser
end

return XMLSAXParser