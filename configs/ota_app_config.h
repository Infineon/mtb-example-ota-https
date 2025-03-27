/******************************************************************************
* File Name:   ota_app_config.h
*
* Description: This file contains the OTA application level configuration macros.
*
* Related Document: See README.md
*
*
*******************************************************************************
* Copyright 2020-2025, Cypress Semiconductor Corporation (an Infineon company) or
* an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
*
* This software, including source code, documentation and related
* materials ("Software") is owned by Cypress Semiconductor Corporation
* or one of its affiliates ("Cypress") and is protected by and subject to
* worldwide patent protection (United States and foreign),
* United States copyright laws and international treaty provisions.
* Therefore, you may use this Software only as provided in the license
* agreement accompanying the software package from which you
* obtained this Software ("EULA").
* If no EULA applies, Cypress hereby grants you a personal, non-exclusive,
* non-transferable license to copy, modify, and compile the Software
* source code solely for use in connection with Cypress's
* integrated circuit products.  Any reproduction, modification, translation,
* compilation, or representation of this Software except as specified
* above is prohibited without the express written permission of Cypress.
*
* Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress
* reserves the right to make changes to the Software without notice. Cypress
* does not assume any liability arising out of the application or use of the
* Software or any product or circuit described in the Software. Cypress does
* not authorize its products for use in any products where a malfunction or
* failure of the Cypress product may reasonably be expected to result in
* significant property damage, injury or death ("High Risk Product"). By
* including Cypress's product in a High Risk Product, the manufacturer
* of such system or application assumes all risk of such use and in doing
* so agrees to indemnify Cypress against all liability.
*******************************************************************************/

#ifndef SOURCE_OTA_APP_CONFIG_H_
#define SOURCE_OTA_APP_CONFIG_H_

/***********************************************
 * Connection configuration
 **********************************************/
/* Name of the Wi-Fi network */
#define WIFI_SSID           "WIFI_SSID"

/* Password for the Wi-Fi network */
#define WIFI_PASSWORD       "WIFI_PASSWORD"

/* Security type of the Wi-Fi access point. See 'cy_wcm_security_t' structure
 * in "cy_wcm.h" for more details.
 */
#define WIFI_SECURITY       (CY_WCM_SECURITY_WPA2_AES_PSK)

/* HTTP Server */
#define HTTP_SERVER         "192.168.0.10"

/* Macro to enable/disable TLS */
#define ENABLE_TLS          (true)

#if (ENABLE_TLS == true)
/* HTTP Server Port */
#define HTTP_SERVER_PORT    (443)
#else
/* HTTP Server Port */
#define HTTP_SERVER_PORT    (8080)
#endif

/* Name of the JSON job file for HTTP  */
#define OTA_HTTP_JOB_FILE    "/ota_update.json"

/**********************************************
 * Certificates and Keys - TLS Mode only
 *********************************************/
/* Root CA Certificate -
   Must include the PEM header and footer:

        "-----BEGIN CERTIFICATE-----\n" \
        ".........base64 data.......\n" \
        "-----END CERTIFICATE-------\n"
*/
#define ROOT_CA_CERTIFICATE ""

/* Client Certificate
   Must include the PEM header and footer:

        "-----BEGIN CERTIFICATE-----\n" \
        ".........base64 data.......\n" \
        "-----END CERTIFICATE-------\n"
*/
#define USING_CLIENT_CERTIFICATE    (true)

#define CLIENT_CERTIFICATE ""

/* Private Key
   Must include the PEM header and footer:

        "-----BEGIN RSA PRIVATE KEY-----\n" \
        "...........base64 data.........\n" \
        "-----END RSA PRIVATE KEY-------\n"
*/
#define USING_CLIENT_KEY    (true)

#define CLIENT_KEY ""

#endif /* SOURCE_OTA_APP_CONFIG_H_ */
