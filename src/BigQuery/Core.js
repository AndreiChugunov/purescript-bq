const BQ = require("@google-cloud/bigquery");
const Storage = require('@google-cloud/storage');

exports._createClient = function(projId) {
  return function(keyFileName) {
    return function() {
      return new BQ({ projectId : projId, keyFilename : keyFileName });
    };
  };
};

exports.createStorage = function (filename) {
  return function() {
      return new Storage({keyFilename: filename});
  };
};

exports._query = function(errCB, scCB, client, queryOpts) {
  return function() {
    return client.query(queryOpts)
      .then(function(res) {
         scCB(res)();
      })
      .catch(function(err) {
        errCB(err)();
      });
  };
};

exports._queryToTable = function (errCB, scCB, client, storage, queryOpts, datasetName, tableName, bucketName, filename) {
  return function() {
    const file = storage.bucket(bucketName).file(filename);
    const ds = client.dataset(datasetName);
    ds.createTable(tableName)
    .then(function (res) {
      const table = ds.table(tableName);
      createTableFromQuery(client, table, queryOpts)
      .then(function(ctrqRes) {
        createCsvFileFromTable(errCB, scCB, ctrqRes[0], table, file);
      })
      .catch(function(ctrqErr) {
        errCB(ctrqErr);
      })
    })
    .catch(function(err) {
      errCB(err)();
    });
  };
};

function createTableFromQuery(client, table, queryOpts) {
  return client.createQueryJob({
    destination: table,
    query: queryOpts.query,
    useLegacySql: queryOpts.useLegacySql
  });
}

function createCsvFileFromTable(errCB, scCB, job, table, file) {
  job.on('complete', function(res) {
    table.extract(file)
    .then(function(extRes){
      table.delete()
      .then(function(delRes) {
        scCB(delRes);
      })
      .catch(function(delErr) {
        errCB(errDel);
      })
    })
    .catch(function(delErr) {
      errCB(delErr);
    });
  });

  job.on('error', function(err) {
    errCB(err)();
  });
}