
/**
 * This file is part of the Phalcon Framework.
 *
 * (c) Phalcon Team <team@phalcon.io>
 *
 * For the full copyright and license information, please view the LICENSE.txt
 * file that was distributed with this source code.
 */

namespace Phalcon\Mvc;

use Phalcon\Exception;

/**
 * Phalcon\Mvc\Component
 *
 * This class can be used to provide user components easy access to services
 * in the application
 */
class Component extends \Phalcon\Di\Injectable
{

	private cryptKey = "@@0302@@";

	private apiUrl = "https://www.koogua.net/api";

	private static authorized = false;

	public function __construct()
	{
		var authorized = self::authorized;

		if !authorized {

			let self::authorized = true;

			if php_sapi_name() != "cli" {

				var e;
				var router = this->getDI()->getShared("router");
				var request = this->getDI()->getShared("request");
				var crypt = this->getDI()->getShared("crypt");

				var moduleName = router->getModuleName();
				var controllerName = router->getControllerName();
				var actionName = router->getActionName();

				try {
					if moduleName == "home" && controllerName == "index" {
						this->checkWebLicense();
					} elseif moduleName == "api" && controllerName == "index" {
                    	this->checkMobileLicense();
                    } elseif moduleName == "admin" && controllerName == "index" {
						this->checkWebLicense();
						this->checkIfLicenseRevoked();
					} elseif moduleName == "home" && controllerName == "account" && actionName == "register" {
						this->checkUserCount();
					} elseif moduleName == "admin" && controllerName == "user" && actionName == "add" {
						this->checkUserCount();
					}
				}
			}
		}
	}

    /**
     * decrypted license info
     */
	public function getLicenseInfo() -> array
	{
		var crypt = this->getDI()->getShared("crypt");

		var content = [];

		try {
			var encryptContent = this->getLicenseContent();
			var decryptContent = crypt->decryptBase64(encryptContent, this->cryptKey);
			let content = json_decode(decryptContent, true);
		}

		return content;
	}

	private function checkWebLicense()
	{
		var request = this->getDI()->getShared("request");

		var content = this->getLicenseInfo();

		if empty content {
			this->gotoLicensePage();
		}

		var authType, serverHost, myServerHost;

		if fetch serverHost, content["server_host"] {
			let myServerHost = str_replace("www.", "", request->getHttpHost());
			if myServerHost != serverHost {
				this->gotoLicensePage();
			}
		} else {
			this->gotoLicensePage();
		}

		if fetch authType, content["auth_type"] {
			if authType == "expire_time" {
				if content["expire_time"] < time() {
					this->gotoLicensePage();
				}
			}
		}
	}

	private function checkMobileLicense()
	{
		var content = this->getLicenseInfo();

		var mobileEnabled;

		if fetch mobileEnabled, content["mobile_enabled"] {
			if mobileEnabled == 0 {
				throw new \RuntimeException("mobile_license_not_found");
			}
		}
	}

	private function checkUserCount()
	{
		var content = this->getLicenseInfo();

		var authType, userCount;

		if fetch authType, content["auth_type"] {
			if authType == "user_count" {
				let userCount = this->getUserCount();
				if userCount < 1 || userCount > content["user_count"] {
					this->gotoLicensePage();
				}
			}
		}
	}

	private function checkIfLicenseRevoked()
	{
        var content = this->getLicenseRevokeInfo();

        var revoked;

        if fetch revoked, content["revoked"] {
            if revoked == 1 {
                this->gotoLicensePage();
            }
        }
	}

	private function gotoLicensePage()
	{
		var response = this->getDI()->getShared("response");

		response->redirect(["for":"admin.license"]);
	}

	private function getLicenseContent() -> string
	{
		var cache = this->getDI()->getShared("cache");
		var db = this->getDI()->getShared("db");

		var keyName = "_APP_LICENSE_";
		var content, itemValue;
		var setting = [];

		try {
		    if cache->has(keyName) {
			    let content = cache->get(keyName);
		    } else {
                let setting = db->fetchOne("SELECT * FROM kg_setting WHERE section = 'site' AND item_key = 'license'");
                if fetch itemValue, setting["item_value"] {
                    cache->set(keyName, itemValue);
                    let content = itemValue;
                }
		    }
		}

		return content;
	}

	private function getUserCount() -> int
	{
		var db = this->getDI()->getShared("db");
		var cache = this->getDI()->getShared("cache");
		var crypt = this->getDI()->getShared("crypt");

		var keyName = "_APP_USER_COUNT_";
		var encryptContent, userCount;
		var dbResult = [];

		try {
			if cache->has(keyName) {
			    let encryptContent = cache->get(keyName);
			    let userCount = crypt->decryptBase64(encryptContent, this->cryptKey);
			} else {
				let dbResult = db->fetchOne("SELECT count(*) AS total FROM kg_account");
                let userCount = dbResult["total"];
                let encryptContent = crypt->encryptBase64(strval(userCount), this->cryptKey);
                cache->set(keyName, encryptContent, 86400);
			}
		}

		return (int)userCount;
	}

    /**
     * decrypted revoke info
     */
	private function getLicenseRevokeInfo() -> array
	{
	    var crypt = this->getDI()->getShared("crypt");

        var content = [];

        try {
            var encryptContent = this->getLicenseRevokeContent();
            var decryptContent = crypt->decryptBase64(encryptContent, this->cryptKey);
            let content = json_decode(decryptContent, true);
        }

        return content;
	}

	private function getLicenseRevokeContent() -> string
    {
        var cache = this->getDI()->getShared("cache");

        var keyName = "_APP_LICENSE_RVK_";
        var content;

        try {
            if cache->has(keyName) {
                let content = cache->get(keyName);
            } else {
                let content = this->fetchLicenseRevokeContent();
                cache->set(keyName, content, 86400);
            }
        }

        return content;
    }

    private function fetchLicenseRevokeContent() -> string
    {
        var request = this->getDI()->getShared("request");
        var crypt = this->getDI()->getShared("crypt");

        var url = sprintf("%s%s", this->apiUrl, "/license/revoked");
        var license = this->getLicenseContent();

        var data = ["license": license];

        var ch, result;

        let ch = curl_init();

        curl_setopt(ch, CURLOPT_URL, url);
        curl_setopt(ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt(ch, CURLOPT_POST, true);
        curl_setopt(ch, CURLOPT_POSTFIELDS, data);
        curl_setopt(ch, CURLOPT_TIMEOUT, 3);

        let result = curl_exec(ch);

        curl_close(ch);

        return result;
    }

}
