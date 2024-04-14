db.tenantProfile.updateOne(
    { "tenantCode" : "TENANT_LOWER" }, // Filter criteria
    { $set: { 
        "serverCname": "TENANT_LOWER.unicommerce.com",
        "serverName": "TENANT"
    }}
);

