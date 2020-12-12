/*
 * Nudr_DataRepository API OpenAPI file
 *
 * Unified Data Repository Service
 *
 * API version: 1.0.0
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package DataRepository_test

import (
	"context"
	"go.mongodb.org/mongo-driver/bson"
	"free5gc/src/udr/logger"
	"net/http"
	"testing"

	"github.com/google/go-cmp/cmp"
	"free5gc/lib/openapi/models"
)

// GetOdbData - Retrieve ODB Data data by SUPI or GPSI
func TestGetOdbData(t *testing.T) {
	runTestServer(t)

	connectMongoDB(t)

	// Drop old data
	collection := Client.Database("free5gc").Collection("subscriptionData.operatorDeterminedBarringData")
	collection.DeleteOne(context.TODO(), bson.M{"ueId": "imsi-0123456789"})

	// Set client and set url
	client := setTestClient(t)

	// Set test data
	ueId := "imsi-0123456789"
	testData := models.OperatorDeterminedBarringData{
		RoamingOdb:        models.RoamingOdb_PLMN,
		OdbPacketServices: models.OdbPacketServices_ALL_PACKET_SERVICES,
	}
	insertTestData := toBsonM(testData)
	insertTestData["ueId"] = ueId
	collection.InsertOne(context.TODO(), insertTestData)

	{
		// Check test data (Use RESTful GET)
		operatorDeterminedBarringData, res, err := client.QueryODBDataBySUPIOrGPSIDocumentApi.GetOdbData(context.TODO(), ueId)
		if err != nil {
			logger.AppLog.Panic(err)
		}

		if status := res.StatusCode; status != http.StatusOK {
			t.Errorf("handler returned wrong status code: got %v want %v",
				status, http.StatusOK)
		}

		if cmp.Equal(testData, operatorDeterminedBarringData, Opt) != true {
			t.Errorf("handler returned unexpected body: got %v want %v",
				operatorDeterminedBarringData, testData)
		}
	}

	// Clean test data
	collection.DeleteOne(context.TODO(), bson.M{"ueId": "imsi-0123456789"})
}
