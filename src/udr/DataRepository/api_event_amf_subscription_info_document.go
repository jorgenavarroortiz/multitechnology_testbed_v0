/*
 * Nudr_DataRepository API OpenAPI file
 *
 * Unified Data Repository Service
 *
 * API version: 1.0.0
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package DataRepository

import (
	"github.com/gin-gonic/gin"
	"free5gc/lib/http_wrapper"
	"free5gc/lib/openapi/models"
	"free5gc/src/udr/logger"
	"free5gc/src/udr/udr_handler/udr_message"
)

// CreateAMFSubscriptions - Creates AMF Subscription Info for an eeSubscription
func CreateAMFSubscriptions(c *gin.Context) {
	var amfSubscriptionInfoArray []models.AmfSubscriptionInfo
	if err := c.ShouldBindJSON(&amfSubscriptionInfoArray); err != nil {
		logger.DataRepoLog.Panic(err.Error())
	}

	req := http_wrapper.NewRequest(c.Request, amfSubscriptionInfoArray)
	req.Params["ueId"] = c.Params.ByName("ueId")
	req.Params["subsId"] = c.Params.ByName("subsId")

	handlerMsg := udr_message.NewHandlerMessage(udr_message.EventCreateAMFSubscriptions, req)
	udr_message.SendMessage(handlerMsg)

	rsp := <-handlerMsg.ResponseChan

	HTTPResponse := rsp.HTTPResponse

	c.JSON(HTTPResponse.Status, HTTPResponse.Body)
}

// RemoveAmfSubscriptionsInfo - Deletes AMF Subscription Info for an eeSubscription
func RemoveAmfSubscriptionsInfo(c *gin.Context) {
	req := http_wrapper.NewRequest(c.Request, nil)
	req.Params["ueId"] = c.Params.ByName("ueId")
	req.Params["subsId"] = c.Params.ByName("subsId")

	handlerMsg := udr_message.NewHandlerMessage(udr_message.EventRemoveAmfSubscriptionsInfo, req)
	udr_message.SendMessage(handlerMsg)

	rsp := <-handlerMsg.ResponseChan

	HTTPResponse := rsp.HTTPResponse

	c.JSON(HTTPResponse.Status, HTTPResponse.Body)
}
