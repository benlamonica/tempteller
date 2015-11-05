package us.pojo.tempteller.service.auth;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.UserInfo;

public interface AuthService {

	AuthResult login(UserInfo userInfo);

	AuthResult addSubscription(String uid, String deviceId, String receipt);

	AuthResult restoreSubscription(String deviceId, String receipt);
}
