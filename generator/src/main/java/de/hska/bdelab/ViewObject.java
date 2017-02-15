package de.hska.bdelab;

public class ViewObject {
	private String timestamp;
	private String ip;
	private String uri;
	private String uniqueIdentifier;
	
	public ViewObject(String timestamp, String ip, String uri, String uid) {
		this.timestamp = timestamp;
		this.ip = ip;
		this.uri = uri;
		this.uniqueIdentifier = uid;
	}
	
	public String getTimestamp() {
		return timestamp;
	}
	public String getIp() {
		return ip;
	}
	public String getUri() {
		return uri;
	}
	public String getUid() {
		return uniqueIdentifier;
	}
}
