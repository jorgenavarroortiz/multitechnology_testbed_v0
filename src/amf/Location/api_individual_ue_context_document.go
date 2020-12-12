/*
 * Namf_Location
 *
 * AMF Location Service
 *
 * API version: 1.0.0
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package Namf_Location

import (
	"free5gc/lib/http_wrapper"
	"free5gc/lib/openapi/models"
	"free5gc/src/amf/amf_handler/amf_message"
	"free5gc/src/amf/logger"
	"net/http"

	"github.com/gin-gonic/gin"
)

// ProvideLocationInfo - Namf_Location ProvideLocationInfo service Operation
func ProvideLocationInfo(c *gin.Context) {

	var request models.RequestLocInfo

	err := c.ShouldBindJSON(&request)
	if err != nil {
		logger.LocationLog.Errorln(err)
	}

	req := http_wrapper.NewRequest(c.Request, request)
	req.Params["ueContextId"] = c.Params.ByName("ueContextId")

	handlerMsg := amf_message.NewHandlerMessage(amf_message.EventProvideLocationInfo, req)
	amf_message.SendMessage(handlerMsg)

	rsp := <-handlerMsg.ResponseChan

	HTTPResponse := rsp.HTTPResponse

	c.JSON(HTTPResponse.Status, HTTPResponse.Body)

}

// ProvidePositioningInfo - Namf_Location ProvidePositioningInfo service Operation
func ProvidePositioningInfo(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{})
}
