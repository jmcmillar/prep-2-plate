class ActionRowData < Struct.new(
  :collection,
  :columns,
  :decorator_classes,
  :user,
  :label_method,
  keyword_init: true
)
end
