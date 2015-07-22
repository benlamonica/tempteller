package us.pojo.weathernotifier.dao;

import java.util.List;
import java.util.Set;

import org.hsqldb.jdbc.JDBCPool;

import us.pojo.weathernotifier.model.SubRequest;
import us.pojo.weathernotifier.model.WeatherData;

public class HsqldbSubDAO implements SubDAO {

	private JDBCPool pool;
	
	public HsqldbSubDAO(String filename) {
		pool = new JDBCPool();
		pool.setUrl("jdbc:hslqdb:file:"+ filename);
		//new SingleConnectionDataSource(url, suppressClose);
	}
	
	public boolean save(SubRequest req) {
		// TODO Auto-generated method stub
		return false;
	}

	public void delete(SubRequest req) {
		// TODO Auto-generated method stub

	}

	public List<String> getUniqueWOEIDs() {
		// TODO Auto-generated method stub
		return null;
	}

	public List<SubRequest> getSubscribers(WeatherData data) {
		// TODO Auto-generated method stub
		return null;
	}

	public void update(SubRequest subRequest) {
		// TODO Auto-generated method stub

	}

	public void deleteInvalidDevices(Set<String> invalidDevices) {
		// TODO Auto-generated method stub

	}

	@Override
	public Set<String> getUniqueLocIds() {
		// TODO Auto-generated method stub
		return null;
	}

}
