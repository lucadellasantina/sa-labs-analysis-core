function responseHandlerMigration_06_Feb_2018(cellData)
  for epoch = cellData.epochs
    epoch.responseHandle = @(e, path) h5read(e.parentCell.get('h5File'), path);
  end
end
