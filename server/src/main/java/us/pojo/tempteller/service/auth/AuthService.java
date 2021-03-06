package us.pojo.tempteller.service.auth;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.LoginRequest;

public interface AuthService {

	AuthResult login(LoginRequest userInfo);

	AuthResult addSubscription(String uid, String deviceId, String receipt);

	AuthResult restoreSubscription(String uid, String deviceId, String receipt);
}
