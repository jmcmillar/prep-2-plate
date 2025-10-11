class ButtonLinkSchemeData
  SYSTEM_SCHEMES = Struct.new(:primary, :light, :link)

  SCHEME_MAP = SYSTEM_SCHEMES[
    "bg-primary text-white font-bold py-2 px-4 rounded text-sm",
    "bg-gray-100 text-dark py-2 px-2 rounded hover:bg-gray-200 text-sm",
    "bg-transparent text-primary font-bold py-2 px-4 rounded hover:bg-gray-100 text-sm"
  ]
end
