function cellData_responseHandlerMigration_20180206(cellData)
  for epoch = cellData.epochs
    epoch.responseHandle = @(e, path) h5read(e.parentCell.get('h5File'), path);
  end
  cellData.attributes('parsedDate') = datetime;
end
