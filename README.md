# Over-the-air firmware update using HTTPS

This code example demonstrates an OTA update with PSoC&trade; 6 MCU and AIROC™ CYW43xxx Wi-Fi & Bluetooth® combo chips. The device establishes a connection with the designated HTTPS server. It periodically checks the job document to see if a new update is available. When a new update is available, it is downloaded and written to the secondary slot. On the next reboot, MCUboot swaps the new image in the secondary slot with the primary slot image and runs the application. If the new image is not validated in runtime, on the next reboot, MCUboot reverts to the previously validated image.

MCUboot is a "secure" bootloader for 32-bit MCUs. See the [README](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic/blob/master/README.md) of the [mtb-example-psoc6-mcuboot-basic](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic) code example for more details.

Over-the-air update middleware library enables the OTA feature. See the [ota-update](https://github.com/Infineon/ota-update) middleware repository on Github for more details.

[View this README on GitHub.](https://github.com/Infineon/mtb-example-ota-https)

[Provide feedback on this code example.](https://cypress.co1.qualtrics.com/jfe/form/SV_1NTns53sK2yiljn?Q_EED=eyJVbmlxdWUgRG9jIElkIjoiQ0UyMzE1ODUiLCJTcGVjIE51bWJlciI6IjAwMi0zMTU4NSIsIkRvYyBUaXRsZSI6Ik92ZXItdGhlLWFpciBmaXJtd2FyZSB1cGRhdGUgdXNpbmcgSFRUUFMiLCJyaWQiOiJ5ZWt0IiwiRG9jIHZlcnNpb24iOiI0LjAuMCIsIkRvYyBMYW5ndWFnZSI6IkVuZ2xpc2giLCJEb2MgRGl2aXNpb24iOiJNQ0QiLCJEb2MgQlUiOiJJQ1ciLCJEb2MgRmFtaWx5IjoiUFNPQyJ9)

## Requirements

- [ModusToolbox&trade; software](https://www.infineon.com/cms/en/design-support/tools/sdk/modustoolbox-software) v2.4 or later
- Board support package (BSP) minimum required version: 3.0.0
- Programming language: C
- Associated parts: All [PSoC&trade; 6 MCU](https://www.infineon.com/cms/en/product/microcontroller/32-bit-psoc-arm-cortex-microcontroller/psoc-6-32-bit-arm-cortex-m4-mcu/) parts with SDIO interface, [AIROC™ CYW43xxx Wi-Fi & Bluetooth® combo chips](https://www.infineon.com/cms/en/product/wireless-connectivity/airoc-wi-fi-plus-bluetooth-combos)

## Supported toolchains (make variable 'TOOLCHAIN')

- GNU Arm® embedded compiler v10.3.1 (`GCC_ARM`) - Default value of `TOOLCHAIN`
- Arm&reg; compiler v6.13 (`ARM`)
- IAR C/C++ compiler v8.42.2 (`IAR`)

## Supported kits (make variable 'TARGET')

- [PSoC&trade; 6 Wi-Fi Bluetooth&reg; prototyping kit](https://www.infineon.com/cms/en/product/evaluation-boards/cy8cproto-062-4343w) (`CY8CPROTO-062-4343W`) - Default value of `TARGET`
- [PSoC&trade; 62S2 Wi-Fi Bluetooth&reg; pioneer kit](https://www.infineon.com/cms/en/product/evaluation-boards/cy8ckit-062s2-43012) (`CY8CKIT-062S2-43012`)
- [PSoC&trade; 62S2 evaluation kit](https://www.infineon.com/cms/en/product/evaluation-boards/cy8ceval-062s2) (`CY8CEVAL-062S2-LAI-4373M2`, `CY8CEVAL-062S2-MUR-43439M2`)

## Hardware setup

This example uses the board's default configuration. See the kit user guide to ensure that the board is configured correctly.

## Software setup

Install a terminal emulator if you do not have one. Instructions in this document use [Tera Term](https://ttssh2.osdn.jp/index.html.en).

This example uses local-web-server to set up a local HTTP server, see [Setting up HTTP/HTTPS server using local-web-server](#setting-up-an-httphttps-server-using-local-web-server-based-on-nodejs) for more details.

## Structure and overview

This code example is a dual-core project, where the MCUboot bootloader app runs on the CM0+ core and the OTA update app runs on the CM4 core. The OTA update app fetches the new image and places it in the flash memory; the bootloader takes care of updating the existing image with the new image. The [mtb-example-psoc6-mcuboot-basic](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic) code example is the bootloader project used for this purpose.

The bootloader project and this OTA update project should be built and programmed independently. They must be placed separately in the workspace as you would do for any other two independent projects. An example workspace will be as follows:

   ```
   <example-workspace>
      |
      |-<mtb-example-psoc6-mcuboot-basic>
      |-<mtb-example-ota-https>
      |
   ```

You must first build and program the MCUboot bootloader project into the CM0+ core; this should be done only once. The OTA update app can then be programmed into the CM4 core; you need to only modify this app for all application purposes.

## Using the code example

Create the project and open it using one of the following:

<details><summary><b>In Eclipse IDE for ModusToolbox&trade; software</b></summary>

1. Click the **New Application** link in the **Quick Panel** (or, use **File** > **New** > **ModusToolbox Application**). This launches the [Project Creator](https://www.infineon.com/dgdl/Infineon-ModusToolbox_Project_Creator_Guide_3-UserManual-v01_00-EN.pdf?fileId=8ac78c8c7d718a49017d99bcabbd31e5) tool.

2. Pick a kit supported by the code example from the list shown in the **Project Creator - Choose Board Support Package (BSP)** dialog.

   When you select a supported kit, the example is reconfigured automatically to work with the kit. To work with a different supported kit later, use the [Library Manager](https://www.infineon.com/dgdl/Infineon-ModusToolbox_Library_Manager_User_Guide_3-UserManual-v01_00-EN.pdf?fileId=8ac78c8c7d718a49017d99ab34b831ce) to choose the BSP for the supported kit. You can use the Library Manager to select or update the BSP and firmware libraries used in this application. To access the Library Manager, click the link from the **Quick Panel**.

   You can also just start the application creation process again and select a different kit.

   If you want to use the application for a kit not listed here, you may need to update the source files. If the kit does not have the required resources, the application may not work.

3. In the **Project Creator - Select Application** dialog, choose the example by enabling the checkbox.

4. (Optional) Change the suggested **New Application Name**.

5. The **Application(s) Root Path** defaults to the Eclipse workspace which is usually the desired location for the application. If you want to store the application in a different location, you can change the *Application(s) Root Path* value. Applications that share libraries should be in the same root path.

6. Click **Create** to complete the application creation process.

For more details, see the [Eclipse IDE for ModusToolbox&trade; software user guide](https://www.infineon.com/dgdl/Infineon-Eclipse_IDE_for_ModusToolbox_User_Guide_1-UserManual-v01_00-EN.pdf?fileId=8ac78c8c7d718a49017d99bcb86331e8) (locally available at *{ModusToolbox&trade; software install directory}/ide_{version}/docs/mt_ide_user_guide.pdf*).

</details>

<details><summary><b>In command-line interface (CLI)</b></summary>

ModusToolbox&trade; software provides the Project Creator as both a GUI tool and the command line tool, "project-creator-cli". The CLI tool can be used to create applications from a CLI terminal or from within batch files or shell scripts. This tool is available in the *{ModusToolbox&trade; software install directory}/tools_{version}/project-creator/* directory.

Use a CLI terminal to invoke the "project-creator-cli" tool. On Windows, use the command line "modus-shell" program provided in the ModusToolbox&trade; software installation instead of a standard Windows command-line application. This shell provides access to all ModusToolbox&trade; software tools. You can access it by typing `modus-shell` in the search box in the Windows menu. In Linux and macOS, you can use any terminal application.

This tool has the following arguments:

Argument | Description | Required/optional
---------|-------------|-----------
`--board-id` | Defined in the `<id>` field of the [BSP](https://github.com/Infineon?q=bsp-manifest&type=&language=&sort=) manifest | Required
`--app-id`   | Defined in the `<id>` field of the [CE](https://github.com/Infineon?q=ce-manifest&type=&language=&sort=) manifest | Required
`--target-dir`| Specify the directory in which the application is to be created if you prefer not to use the default current working directory | Optional
`--user-app-name`| Specify the name of the application if you prefer to have a name other than the example's default name | Optional

<br>

The following example will clone the "[mtb-example-ota-https](https://github.com/Infineon/mtb-example-anycloud-ota-https)" application with the desired name "OtaHttps" configured for the *CY8CPROTO-062-4343W* BSP into the specified working directory, *C:/mtb_projects*:

   ```
   project-creator-cli --board-id CY8CPROTO-062-4343W --app-id mtb-example-ota-https --user-app-name OtaHttps --target-dir "C:/mtb_projects"
   ```

**Note:** The project-creator-cli tool uses the `git clone` and `make getlibs` commands to fetch the repository and import the required libraries. For details, see the "Project creator tools" section of the [ModusToolbox&trade; software user guide](https://www.infineon.com/dgdl/Infineon-ModusToolbox_2.4_User_Guide-Software-v01_00-EN.pdf?fileId=8ac78c8c7e7124d1017ed97e72563632) (locally available at *{ModusToolbox&trade; software install directory}/docs_{version}/mtb_user_guide.pdf*).

</details>

<details><summary><b>In third-party IDEs</b></summary>

Use one of the following options:

- **Use the standalone [Project Creator](https://www.infineon.com/dgdl/Infineon-ModusToolbox_Project_Creator_Guide_3-UserManual-v01_00-EN.pdf?fileId=8ac78c8c7d718a49017d99bcabbd31e5) tool:**

   1. Launch Project Creator from the Windows Start menu or from *{ModusToolbox&trade; software install directory}/tools_{version}/project-creator/project-creator.exe*.

   2. In the initial **Choose Board Support Package** screen, select the BSP, and click **Next**.

   3. In the **Select Application** screen, select the appropriate IDE from the **Target IDE** drop-down menu.

   4. Click **Create** and follow the instructions printed in the bottom pane to import or open the exported project in the respective IDE.

<br>

- **Use command-line interface (CLI):**

   1. Follow the instructions from the **In command-line interface (CLI)** section to create the application, and then import the libraries using the `make getlibs` command.

   2. Export the application to a supported IDE using the `make <ide>` command.

   3. Follow the instructions displayed in the terminal to create or import the application as an IDE project.

For a list of supported IDEs and more details, see the "Exporting to IDEs" section of the [ModusToolbox&trade; software user guide](https://www.infineon.com/dgdl/Infineon-ModusToolbox_2.4_User_Guide-Software-v01_00-EN.pdf?fileId=8ac78c8c7e7124d1017ed97e72563632) (locally available at *{ModusToolbox&trade; software install directory}/docs_{version}/mtb_user_guide.pdf*).

</details>

## Building and programming MCUboot

The [mtb-example-psoc6-mcuboot-basic](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic) code example bundles two applications: the bootloader app that runs on CM0+, and the Blinky app that runs on CM4. For this code example, only the bootloader app is required and the root directory of the bootloader app is referred to as *\<bootloader_cm0p>* in this document.

1. Import the [mtb-example-psoc6-mcuboot-basic](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic) code example per the instructions in the [Using the code example](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic#using-the-code-example) section of its [README](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic/blob/master/README.md).

2. The bootloader and OTA applications must have the same understanding of the memory layout. The memory layout is defined through JSON files. The ota-update library provides a set of predefined JSON files that can be readily used. Both the bootloader and OTA application must use the same JSON file.

   The *\<mtb_shared>/ota-update/\<tag>/configs/flashmap/* folder contains the predefined flashmap JSON files. The files with prefix **psoc62_2m_** are supported by this example.

   Copy the required flashmap JSON file and paste it in the *\<bootloader_cm0p>/flashmap* folder.

3. Modify the value of the `FLASH_MAP` variable in  *\<bootloader_cm0p>/shared_config.mk* to the selected JSON file name from the previous step.

4. Copy the *\<mtb_shared>/mcuboot/\<tag>/boot/cypress/MCUBootApp/config* folder and paste it in the *\<bootloader_cm0p>* folder. 

5. Edit the *\<bootloader_cm0p>/config/mcuboot_config/mcuboot_config.h* file and comment out the following defines to skip checking the image signature:

   ```
   #define MCUBOOT_SIGN_EC256
   .
   .
   .
   #define MCUBOOT_VALIDATE_PRIMARY_SLOT
   ```

6. Edit *\<bootloader_cm0p>/app.mk* and replace the MCUboot include `$(MCUBOOTAPP_PATH)/config` with `./config`. This gets the build system to find the new copy of the config directory that you pasted in the *\<bootloader_cm0p>* directory, instead of the default one supplied by the library.

7. Connect the board to your PC using the provided USB cable through the KitProg3 USB connector.

8. Open a CLI terminal.

   On Linux and macOS, you can use any terminal application. On Windows, open the **modus-shell** app from the Start menu.

9. Navigate the terminal to the *\<mtb_shared>/mcuboot/\<tag>/scripts* folder.

10. Run the following command to ensure that the required modules are installed or already present ("Requirement already satisfied:" is printed).

      ```
      pip install -r requirements.txt
      ```

11. Open a serial terminal emulator and select the KitProg3 COM port. Set the serial port parameters to 8N1 and 115200 baud.

12. Build and program the application per the [Step-by-step](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic#step-by-step-instructions) instructions in its [README](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic/blob/master/README.md).

    After programming, the bootloader application starts automatically.

    **Figure 1. Booting with no bootable image**

    ![](images/booting_without_bootable_image.png)

**Note:** This example does not demonstrate securely upgrading the image and booting from it using features such as image-signing and secured boot. See the [PSoC&trade; 64 line of "Secure" MCUs](https://www.infineon.com/cms/en/product/microcontroller/32-bit-psoc-arm-cortex-microcontroller/psoc-6-32-bit-arm-cortex-m4-mcu/psoc-64) that offer all those features built around MCUboot.

## Setting up an HTTP/HTTPS server using local-web-server (based on *node.js*)

This code example uses a local server to demonstrate the OTA operation over HTTP/HTTPS. [local-web-server](https://www.npmjs.com/package/local-web-server) is used by this example. It is a lean, modular web server for rapid full-stack development.

The root directory of the OTA application is referred to as *\<OTA Application>* in this document.

1. Download and install [node.js](https://nodejs.org/en/download/). Perform the installation with default settings. **Do not tick** the checkbox to install optional tools for native modules.

2. Open a CLI terminal.

   On Linux and macOS, you can use any terminal application. On Windows, open the **modus-shell** app from the Start menu.

3. Navigate to the *\<OTA Application>/scripts/* folder.

4. Execute the following command to generate self-signed SSL certificates and keys. On Linux and macOS, you can get your device-local IP address by running the `ifconfig` command on any terminal application. On Windows, run the `ipconfig` command on a command prompt.

   ```
   sh generate_ssl_cert.sh <local-ip-address-of-your-pc>
   ```

   Example:
   ```
   sh generate_ssl_cert.sh 192.168.0.10
   ```

   This step will generate the following files in the same *\<OTA Application>/scripts/* directory:

   1. *http_ca.crt* - Root CA certificate
   2. *http_ca.key* - Root CA private key
   3. *http_server.crt* - Server certificate
   4. *http_server.key* - Server private key
   5. *http_client.crt* - Client certificate
   6. *http_client.key* - Client private key

5. Execute the following command to install [local-web-server](https://www.npmjs.com/package/local-web-server).

   ```
   npm install -g local-web-server
   ```

6. Start the local HTTP/HTTPS server:

   - **Using the code example in TLS mode (default):** Execute the following command:

      ```
      ws -p 4443 --hostname <local-ip-address-of-your-pc> --https --key http_server.key --cert http_server.crt --keep-alive-timeout 10000 -v
      ```

      Example:
      ```
      ws -p 4443 --hostname 192.168.0.10 --https --key http_server.key --cert http_server.crt --keep-alive-timeout 10000 -v
      ```
      **Figure 2. HTTPS server started in TLS Mode**

      ![](images/https_tls_mode.png)


   - **Using the code example in non-TLS mode:** Execute the following command:

      ```
      ws -p 8080 --hostname <local-ip-address-of-your-pc> --keep-alive-timeout 10000 -v
      ```

      Example:
      ```
      ws -p 8080 --hostname 192.168.0.10 --keep-alive-timeout 10000 -v
      ```

      **Figure 3. HTTPS server started in Non TLS Mode**

      ![](images/https_non_tls_mode.png)

**Note:** If you are running local-web-server server on a device which is maintained by your organization or institution, the firewall settings may not permit you to host a file server on the local network. To verify whether the file server has been hosted properly, from a device connected to the same local network, check the server link on a browser. Browse for `http://<ip-address-noted-earlier>:<port-number-noted-earlier>`; for example: `http://192.168.0.10:8080`. If the files in the *\<OTA Application>/scripts/* directory are listed on the browser page, you have a properly working file server. Do not proceed to the next section without getting the file server to work.


## Operation

1. Connect the board to your PC using the provided USB cable through the KitProg3 USB connector.

2. Open a terminal program and select the KitProg3 COM port. Set the serial port parameters to 8N1 and 115200 baud.

3. Modify the `OTA_FLASH_MAP` variable in the *\<OTA Application>/Makefile* to change the JSON file name to match the selection made while programming the bootloader application.

4. Edit the *\<OTA Application>/source/ota_app_config.h* file to configure your OTA application:

   1. Modify the connection configuration such as the `WIFI_SSID`, `WIFI_PASSWORD`, and `WIFI_SECURITY` macros to match the settings of your Wi-Fi network. Make sure that the device running the HTTP server and the kit are connected to the same network.

   2. Modify the `HTTP_SERVER` address to match the IP address of your HTTP server.

   3. By default, this code example uses HTTPS (TLS) protocol. To use the example in HTTP (non-TLS) mode, modify `ENABLE_TLS` to **false** and skip the next step of adding the certificate.

   4. Add the certificates and key:

      1. Open a CLI terminal.

          On Linux and macOS, you can use any terminal application. On Windows, open the "modus-shell" app from the Start menu.

      2. Navigate the terminal to *\<OTA Application>/scripts/* directory.

      3. Run the *format_cert_key.py* Python script to generate the string format of the *http_ca.crt* file that can be added as a macro. Pass the name of the certificate with the extension as an argument to the Python script:

         ```
         python format_cert_key.py <one-or-more-file-name-of-certificate-or-key-with-extension>
         ```

         Example:
         ```
         python format_cert_key.py http_ca.crt
         ```
      4. Copy the generated string and add it to the `ROOT_CA_CERTIFICATE` macro in the *ota_app_config.h* file per the sample shown.

      Note that the local-web-server does not authenticate a client through the certificate; this is the reason why the client certificate and client key are not added here. If you use some other server, which can do client-side authentication, add the *http_client.crt* and *http_client.key* files. Also, set the `USING_CLIENT_CERTIFICATE` and `USING_CLIENT_KEY` macros to value **true**.

5. Edit the job document (*\<OTA Application>/scripts/ota_update.json*):

   1. Modify the value of `Server` to match the IP address of your HTTP server.

   2. Modify the value of `Board` to match the kit you are using.

   3. In Step 3, if the code example has been configured to work in non-TLS mode: Set the value of `Port` to **8080**, and `Connection` to **HTTP**.

6. Build and program the board.

   <details open><summary><b>Using Eclipse IDE for ModusToolbox&trade;</b></summary>

      1. Select the application project in the Project Explorer.

      2. In the **Quick Panel**, scroll down, and click **\<Application Name> Program (KitProg3_MiniProg4)**.
   </details>

   <details open><summary><b>Using CLI</b></summary>

     From the terminal, execute the `make program` command to build and program the application using the default toolchain to the default target. You can specify a target and toolchain manually:
      ```
      make program TARGET=<BSP> TOOLCHAIN=<toolchain>
      ```

      Example:
      ```
      make program TARGET=CY8CPROTO-062-4343W TOOLCHAIN=GCC_ARM
      ```
   </details>

   At this point, the primary slot is programmed and the CM4 CPU starts running the image from the primary slot on reset. Observe the messages on the UART terminal; wait for the device to make the required connections as shown in Figure 4. Also, the user LED will blink at 1 Hz.

   **Figure 4. Connection to the HTTP server**

   ![](images/connection_http_server.png)

7. The job document placed in the *\<OTA Application>/scripts/* folder has a value of `Version` as **1.0.0**. Because the OTA application version and the available update version are the same, the update will not happen.

8. Modify the value of the `BLINKY_DELAY_MS` macro to **(100)** in the *\<OTA Application>/source/led_task.c* file and change the app version in the *\<OTA Application>/Makefile* by setting `APP_VERSION_MINOR` to **1**.

9. Build the app (**DO NOT** program it to the kit). This new image will be uploaded to the HTTP server in the following steps to demonstrate the OTA update.

   <details open><summary><b>Using Eclipse IDE for ModusToolbox&trade;</b></summary>

      1. Select the application project in the Project Explorer.

      2. In the **Quick Panel**, scroll down, and click **Build \<OTA Application> Application**.
   </details>

   <details open><summary><b>Using CLI</b></summary>

      1. From the terminal, execute the `make build` command to build the application using the default toolchain to the default target. You can specify a target and toolchain manually:
         ```
         make build TARGET=<BSP> TOOLCHAIN=<toolchain>
         ```
         Example:
         ```
         make build TARGET=CY8CPROTO-062-4343W TOOLCHAIN=GCC_ARM
         ```
   </details>

10. After a successful build, copy the *mtb-example-ota-https.bin* file from *\<OTA Application>/build/\<KIT>/Debug* and paste it to the *\<OTA Application>/scripts* directory.

11. Edit the *\<OTA Application>/scripts/ota_update.json* file to modify the value of `Version` to **1.1.0**.

12. The OTA application now finds the updated job document, downloads the new image, and places it in the secondary slot. Once the download is complete, a soft reset is issued. The MCUboot bootloader starts the image upgrade process. It will take approximately 15-20 minutes.

    **Figure 5. Image download**

    ![](images/downloading_new_image.png)

13. After the image upgrade is successfully completed, observe that the user LED is now blinking at 5 Hz.

14. To test the revert feature of MCUboot, send a bad image as the v1.2.0 OTA update. The bad image used in this example is an infinite loop. The watchdog timer will reset the bad image and upon reboot, MCUboot will revert the primary image back to v1.1.0 good image. Edit *\<OTA Application>/Makefile* and add `TEST_REVERT` to the `Defines` variable as shown:

      ```
      DEFINES+=CY_RTOS_AWARE TEST_REVERT
      ```

15. Edit the app version in the *\<OTA Application>/Makefile* by setting `APP_VERSION_MINOR` to **2**.

16. Build the application per Step 8.

17. After a successful build, copy the *mtb-example-ota-https.bin* file from *\<OTA Application>/build/\<KIT>/Debug* and paste it into the *\<OTA Application>/scripts* directory.

18. Edit the *\<OTA Application>/scripts/ota_update.json* file to modify the value of `Version` to **1.2.0**.

19. The OTA application will now find this new v1.2.0 image and update to it. After the update, within a few seconds, the watchdog timer resets the devices. Upon reset, MCUboot reverts to the v1.1.0 good image.

    **Figure 6. Reverting to good image**

    ![](images/reverting_to_good_image.png)


**Note:** After completing the last step, the device will be running the v1.1.0 good image and the server will still have the v1.2.0 bad image. Since the version of the image on the server is greater than the version of the image on the device, the device will re-download the v1.2.0 bad image. This causes an infinite upgrade and revert cycle. To avoid this scenario, stop the HTTP/HTTPS server after you test the code example. In a production environment, the application is responsible for blacklisting bad image versions and avoid upgrading to them in the future.

## Debugging

You can debug the example to step through the code. In the IDE, use the **\<OTA Application> Debug (KitProg3_MiniProg4)** configuration in the **Quick Panel**. For more details, see the "Program and debug" section in the [Eclipse IDE for ModusToolbox&trade; user guide](https://www.infineon.com/dgdl/Infineon-Eclipse_IDE_for_ModusToolbox_User_Guide_1-UserManual-v01_00-EN.pdf?fileId=8ac78c8c7d718a49017d99bcb86331e8).

**Note:** **(Only while debugging)** On the CM4 CPU, some code in `main()` may execute before the debugger halts at the beginning of `main()`. This means that some codes execute twice - once before the debugger stops execution, and again after the debugger resets the program counter to the beginning of `main()`. See [KBA231071](https://community.infineon.com/t5/Knowledge-Base-Articles/PSoC-6-MCU-Code-in-main-executes-before-the-debugger-halts-at-the-first-line-of/ta-p/253856) to learn about this and for the workaround.

## Design and implementation

This example implements two RTOS tasks: OTA client and LED blink. Both these tasks are independent and do not communicate with each other. The OTA client task initializes the dependent middleware and starts the OTA agent. The LED task blinks the user LED at a specified delay.

All the source files related to the two tasks are placed under the *\<OTA Application>/source/* directory:

 File | Description
:-----|:------
*ota_task.c*| Contains the task and functions related to the OTA client.
*ota_task.h* | Contains the public interfaces for the OTA client task.
*led_task.c* | Contains the task and functions related to LED blinking.
*led_task.h* | Contains the public interfaces for the LED blink task.
*main.c* | Initializes the BSP and the retarget-io library, and creates the OTA client and LED blink tasks.
*ota_app_config.h* | Contains the OTA and Wi-Fi configuration macros such has SSID, password, HTTP/HTTPS server details, certificates, and key.
*heap_usage* | Contains the code for printing heap usage.

All the scripts and configurations needed for this example are placed under the *\<OTA Application>/scripts/* directory:

 File | Description
:-----|:------
*generate_ssl_cert.sh*| Shell script to generate the required self-signed CA, server, and client certificates.
*ota_update.json* | OTA job document.
*format_cert_key.py* | Python script to convert certificate/key to string format.

<br>

The *\<OTA Application>/configs/* folder contains other configurations related to the OTA middleware and FreeRTOS.

The flow of the OTA update feature using HTTP can be represented as shown in Figure 4. The application which needs the OTA updates should run the OTA Agent. The OTA Agent spawns threads to receive OTA updates when available, without intervening with the application's core functionality. The initial application resides in the primary slot of the flash memory.

When the OTA Agent receives an update, the new image is placed in the secondary slot of the flash memory. On the next reboot, MCUboot will copy the image from the secondary slot into the primary slot and then CM4 will boot the upgraded image from the primary slot.

**Figure 7. Overview of OTA update using HTTPS**

![](images/ota_http_update_flow.png)

For more details on the features and configurations offered by the [ota-update](https://github.com/Infineon/ota-update) library, see its [README](https://github.com/Infineon/ota-update/blob/master/README.md).

Both MCUboot and the application must have an identical understanding of the memory layout. Otherwise, the bootloader may consider an authentic image as invalid. For more details on the features and configurations of MCUboot-based bootloader, see the [README](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic/blob/master/README.md) of the [mtb-example-psoc6-mcuboot-basic](https://github.com/Infineon/mtb-example-psoc6-mcuboot-basic) code example.

### Resources and settings


**Table 1. Application resources**

 Resource  |  Alias/object     |    Purpose
 :------- | :------------    | :------------
 UART (HAL)|cy_retarget_io_uart_obj| UART HAL object used by retarget-io for the debug UART port
 GPIO (HAL)| CYBSP_USER_LED    | User LED      

<br>

## Related resources

Resources | Links
----------|----------
Application notes  | [AN228571](https://www.infineon.com/dgdl/Infineon-AN228571_Getting_started_with_PSoC_6_MCU_on_ModusToolbox_software-ApplicationNotes-v06_00-EN.pdf?fileId=8ac78c8c7cdc391c017d0d36de1f66d1) – Getting started with PSoC&trade; 6 MCU on ModusToolbox&trade; software <br>  [AN215656](https://www.infineon.com/dgdl/Infineon-AN215656_PSoC_6_MCU_Dual-CPU_System_Design-ApplicationNotes-v09_00-EN.pdf?fileId=8ac78c8c7cdc391c017d0d3180c4655f) – PSoC&trade; 6 MCU: Dual-CPU system design
Code examples  | [Using ModusToolbox&trade; software](https://github.com/Infineon/Code-Examples-for-ModusToolbox-Software) on GitHub
Device documentation | [PSoC&trade; 6 MCU datasheets](https://documentation.infineon.com/html/psoc6/bnm1651211483724.html) <br> [PSoC&trade; 6 technical reference manuals](https://documentation.infineon.com/html/psoc6/zrs1651212645947.html)
Development kits | Select your kits from the [evaluation board finder](https://www.infineon.com/cms/en/design-support/finder-selection-tools/product-finder/evaluation-board) page
Libraries on GitHub  | [mtb-pdl-cat1](https://github.com/Infineon/mtb-pdl-cat1) – PSoC&trade; 6 peripheral driver library (PDL)  <br> [mtb-hal-cat1](https://github.com/Infineon/mtb-hal-cat1) – Hardware abstraction layer (HAL) library <br> [retarget-io](https://github.com/Infineon/retarget-io) – Utility library to retarget STDIO messages to a UART port
Middleware on GitHub  | [ota-update](https://github.com/Infineon/ota-update) – OTA library and docs <br> [wifi-mw-core](https://github.com/Infineon/wifi-mw-core) – Wi-Fi middleware core library and docs <br> [psoc6-middleware](https://github.com/Infineon/modustoolbox-software#psoc-6-middleware-libraries) – Links to all PSoC&trade; 6 MCU middleware
Tools  | [Eclipse IDE for ModusToolbox&trade; software](https://www.infineon.com/cms/en/design-support/tools/sdk/modustoolbox-software) – ModusToolbox&trade; software is a collection of easy-to-use software and tools enabling rapid development with Infineon MCUs, covering applications from embedded sense and control to wireless and cloud-connected systems using AIROC&trade; Wi-Fi and Bluetooth® connectivity devices.

## Other resources

Infineon provides a wealth of data at www.infineon.com to help you select the right device, and quickly and effectively integrate it into your design.

For PSoC&trade; 6 MCU devices, see [How to design with PSoC&trade; 6 MCU - KBA223067](https://community.infineon.com/t5/Knowledge-Base-Articles/How-to-Design-with-PSoC-6-MCU-KBA223067/ta-p/248857) in the Infineon community.


## Document history

Document title: *CE231585* – *Over-the-air firmware update using HTTPS*

 Version | Description of change
 ------- | ---------------------
 1.0.0   | New code example
 1.1.0   | Updated the configuration file to support MbedTLS v2.22.0
 2.0.0   | Update to:<br>1. Support anycloud-ota v4.X library. <br>2. Support swap upgrade with MCUboot. <br>3. Support local-web-server instead of mongoose
 3.0.0   | Update to support ModusToolbox&trade; software v2.4 and BSP v3.X<br /> Added support for CY8CEVAL-062S2-MUR-43439M2 and CY8CEVAL-062S2-LAI-4373M2 kits
 4.0.0   | Updated the example to use the new ota-update v1.0.0 library

<br>

----------
© Cypress Semiconductor Corporation, 2020-2022. This document is the property of Cypress Semiconductor Corporation, an Infineon Technologies company, and its affiliates ("Cypress").  This document, including any software or firmware included or referenced in this document ("Software"), is owned by Cypress under the intellectual property laws and treaties of the United States and other countries worldwide.  Cypress reserves all rights under such laws and treaties and does not, except as specifically stated in this paragraph, grant any license under its patents, copyrights, trademarks, or other intellectual property rights.  If the Software is not accompanied by a license agreement and you do not otherwise have a written agreement with Cypress governing the use of the Software, then Cypress hereby grants you a personal, non-exclusive, nontransferable license (without the right to sublicense) (1) under its copyright rights in the Software (a) for Software provided in source code form, to modify and reproduce the Software solely for use with Cypress hardware products, only internally within your organization, and (b) to distribute the Software in binary code form externally to end users (either directly or indirectly through resellers and distributors), solely for use on Cypress hardware product units, and (2) under those claims of Cypress’s patents that are infringed by the Software (as provided by Cypress, unmodified) to make, use, distribute, and import the Software solely for use with Cypress hardware products.  Any other use, reproduction, modification, translation, or compilation of the Software is prohibited.
<br>
TO THE EXTENT PERMITTED BY APPLICABLE LAW, CYPRESS MAKES NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, WITH REGARD TO THIS DOCUMENT OR ANY SOFTWARE OR ACCOMPANYING HARDWARE, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  No computing device can be absolutely secure.  Therefore, despite security measures implemented in Cypress hardware or software products, Cypress shall have no liability arising out of any security breach, such as unauthorized access to or use of a Cypress product. CYPRESS DOES NOT REPRESENT, WARRANT, OR GUARANTEE THAT CYPRESS PRODUCTS, OR SYSTEMS CREATED USING CYPRESS PRODUCTS, WILL BE FREE FROM CORRUPTION, ATTACK, VIRUSES, INTERFERENCE, HACKING, DATA LOSS OR THEFT, OR OTHER SECURITY INTRUSION (collectively, "Security Breach").  Cypress disclaims any liability relating to any Security Breach, and you shall and hereby do release Cypress from any claim, damage, or other liability arising from any Security Breach.  In addition, the products described in these materials may contain design defects or errors known as errata which may cause the product to deviate from published specifications. To the extent permitted by applicable law, Cypress reserves the right to make changes to this document without further notice. Cypress does not assume any liability arising out of the application or use of any product or circuit described in this document. Any information provided in this document, including any sample design information or programming code, is provided only for reference purposes.  It is the responsibility of the user of this document to properly design, program, and test the functionality and safety of any application made of this information and any resulting product.  "High-Risk Device" means any device or system whose failure could cause personal injury, death, or property damage.  Examples of High-Risk Devices are weapons, nuclear installations, surgical implants, and other medical devices.  "Critical Component" means any component of a High-Risk Device whose failure to perform can be reasonably expected to cause, directly or indirectly, the failure of the High-Risk Device, or to affect its safety or effectiveness.  Cypress is not liable, in whole or in part, and you shall and hereby do release Cypress from any claim, damage, or other liability arising from any use of a Cypress product as a Critical Component in a High-Risk Device. You shall indemnify and hold Cypress, including its affiliates, and its directors, officers, employees, agents, distributors, and assigns harmless from and against all claims, costs, damages, and expenses, arising out of any claim, including claims for product liability, personal injury or death, or property damage arising from any use of a Cypress product as a Critical Component in a High-Risk Device. Cypress products are not intended or authorized for use as a Critical Component in any High-Risk Device except to the limited extent that (i) Cypress’s published data sheet for the product explicitly states Cypress has qualified the product for use in a specific High-Risk Device, or (ii) Cypress has given you advance written authorization to use the product as a Critical Component in the specific High-Risk Device and you have signed a separate indemnification agreement.
<br>
Cypress, the Cypress logo, and combinations thereof, WICED, ModusToolbox, PSoC, CapSense, EZ-USB, F-RAM, and Traveo are trademarks or registered trademarks of Cypress or a subsidiary of Cypress in the United States or in other countries. For a more complete list of Cypress trademarks, visit cypress.com. Other names and brands may be claimed as property of their respective owners.
