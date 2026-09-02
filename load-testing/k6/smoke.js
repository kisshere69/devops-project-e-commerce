import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 20,
  duration: '5m',
};

export default function () {
  http.get('http://app:5000/');
  http.get('http://app:5000/cart');
  http.get('http://app:5000/wishlist');

  sleep(1);
}